require 'yaml'
require 'json'
require 'pg'
require 'logger'

def help_message
  <<-EOF
  Usage: #{$0} <configuration_file_path>
  EOF
end

def main

  if ARGV.count < 1
    puts help_message
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)
  db = config["db"]
  conn = PG::Connection.open(db)
  tenant = config["tenant"]
  single_run = config["single_run"]

  if tenant.nil?
    tenant = []
    conn.exec("SELECT nspname FROM pg_namespace").each do |value|
      unless (value["nspname"].start_with?("pg_") or value["nspname"] == "public" or value["nspname"] == "information_schema")
        tenant << value["nspname"]
      end
    end
  elsif tenant.class == String
    tenant = [tenant]
  end

  app_root_path = config["app_root_path"]

  logger = Logger.new("#{app_root_path}/log/cache_update_daemon.log")

  logger.info "cache daemon starting"

  if single_run

    start_time = Time.now

    execute_job(logger) do
      tenant.each do |t|
        cache_generate_rankings(conn, t, logger)
        cache_generate_votes(conn, t, logger)
      end
    end

    elapsed_time = Time.now - start_time
    logger.info "jobs executed; elapsed time: #{elapsed_time}s"

  else

    loop do
      start_time = Time.now

      execute_job(logger) do
        tenant.each do |t|
          cache_generate_rankings(conn, t, logger)
          cache_generate_votes(conn, t, logger)
        end
      end

      elapsed_time = Time.now - start_time
      logger.info "jobs executed; elapsed time: #{elapsed_time}s"
      sleep(20 * 60) # 20 minutes
    end

  end

end

def cache_generate_rankings(conn, tenant, logger)
  anonymous_user_ids = execute_query(conn, "SELECT id FROM #{tenant + '.' if tenant}users WHERE anonymous_id IS NOT NULL").field_values("id")
  rankings = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}rankings")

  rankings.each do |r|
    start_time = Time.now

    reward_id = r["reward_id"]
    name = r["name"]

    cache = execute_query(conn, "SELECT max(version) FROM #{tenant + '.' if tenant}cache_versions WHERE name = '#{name}'").first

    if cache['max'].nil?
      new_cache_version = 1
    else
      cache_version = cache["max"].to_i
      new_cache_version = cache["max"].to_i + 1
      result = execute_query(conn, "DELETE FROM #{tenant + '.' if tenant}cache_rankings WHERE name = '#{name}' AND version <> #{cache_version}")
      if result.cmd_tuples > 0
        logger.info "cache rankings with name #{name} and version != #{cache_version} deleted (#{result.cmd_tuples} rows)"
      end
    end

    period = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}periods WHERE start_datetime < now() AND end_datetime > now() 
                                    AND kind = '#{r["period"]}'")
    period_id_condition = period.values.empty? ? "ur.period_id is null" : "ur.period_id = #{period.first["id"]}"
    res = execute_query(conn, "SELECT ur.user_id, ur.counter, u.username, u.avatar_selected_url, u.first_name, u.last_name FROM 
                              #{tenant + '.' if tenant}user_rewards ur INNER JOIN #{tenant + '.' if tenant}users u ON u.id = ur.user_id
                              WHERE (
                                ur.reward_id = #{reward_id} AND #{period_id_condition} 
                                AND ur.user_id NOT IN (#{anonymous_user_ids.join(",")})
                              ) 
                              ORDER BY ur.counter DESC, ur.updated_at ASC, ur.user_id ASC")

    res.each_with_index do |user_res, i|
      hash = { "username" =>  nullify_or_escape_string(conn, user_res["username"]), "avatar_selected_url" => user_res["avatar_selected_url"], 
                "first_name" => nullify_or_escape_string(conn, user_res["first_name"]), "last_name" => nullify_or_escape_string(conn, user_res["last_name"]), 
                  "counter" => user_res["counter"].to_i }
      execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_rankings (name, version, user_id, position, data, created_at, updated_at) 
                            VALUES ('#{name}', #{new_cache_version}, #{user_res['user_id']}, #{i + 1}, '#{hash.to_json}', now(), now())")

      # In order to avoid database stressing, the loop will sleep for 1 second every 1000 lines inserted into cache_rankings table
      if i % 500 == 0 and i != 0
        sleep(1)
      end

    end

    hash = { "total" => res.count }
    if cache["max"].nil?
      execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_versions (name, version, data, created_at, updated_at) 
                            VALUES ('#{name}', #{new_cache_version}, '#{hash.to_json}', now(), now())")
    else
      execute_query(conn, "UPDATE #{tenant + '.' if tenant}cache_versions 
                            SET version = #{new_cache_version}, created_at = now(), updated_at = now() WHERE name = '#{name}'")  
    end

    logger.info "cache ranking for #{name} successfully updated to version #{new_cache_version}: #{Time.now - start_time}"

  end

end

def cache_generate_votes(conn, tenant, logger)
  start_time = Time.now

  votes = execute_query(conn, "SELECT call_to_action_id, sum((user_interactions.aux::json->>'vote')::integer) AS sum, count(*) AS count 
                                FROM #{tenant + '.' if tenant}interactions JOIN #{tenant + '.' if tenant}user_interactions 
                                ON interactions.id = user_interactions.interaction_id 
                                JOIN #{tenant + '.' if tenant}call_to_actions ON interactions.call_to_action_id = call_to_actions.id 
                                WHERE interactions.resource_type = 'Vote' AND call_to_actions.activated_at IS NOT NULL 
                                GROUP BY call_to_action_id")

  cache = execute_query(conn, "SELECT max(version) FROM #{tenant + '.' if tenant}cache_versions WHERE name = 'votes-chart'").first

  if cache["max"].nil?
    new_cache_version = 1
  else
    cache_version = cache["max"].to_i
    new_cache_version = cache["max"].to_i + 1
    result = execute_query(conn, "DELETE FROM #{tenant + '.' if tenant}cache_votes WHERE version <> #{cache_version}")
    if result.cmd_tuples > 0
      logger.info "cache votes with version != #{cache_version} deleted (#{result.cmd_tuples} rows)"
    end
  end

  votes.each_with_index do |vote, i|

    call_to_action = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}call_to_actions WHERE id = #{vote['call_to_action_id']}").first

    hash = { "cta_title" => nullify_or_escape_string(conn, call_to_action["title"]) }

    if call_to_action['user_id'] != nil
      user_res = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}users WHERE id = #{call_to_action['user_id']}").first
      gallery_res = execute_query(conn, "SELECT t1.name FROM #{tenant + '.' if tenant}tags t1
                                        LEFT OUTER JOIN #{tenant + '.' if tenant}tags_tags ON t1.id = tags_tags.tag_id 
                                        LEFT OUTER JOIN #{tenant + '.' if tenant}tags t2 ON t2.id = tags_tags.other_tag_id
                                        LEFT OUTER JOIN #{tenant + '.' if tenant}call_to_action_tags ct ON ct.tag_id = t1.id 
                                        WHERE t2.name = 'gallery' AND ct.call_to_action_id = #{call_to_action['id'].to_i}").first

      hash = hash.merge({ "user_id" => user_res["id"], "username" =>  nullify_or_escape_string(conn, user_res["username"]), "avatar_selected_url" => user_res["avatar_selected_url"], 
                  "first_name" => nullify_or_escape_string(conn, user_res["first_name"]), "last_name" => nullify_or_escape_string(conn, user_res["last_name"]) })

      gallery_name = "'#{nullify_or_escape_string(conn, gallery_res["name"])}'"
    else
      hash = hash.merge({ "user_id" => nil })
      gallery_name = "NULL"
    end

    execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_votes (version, call_to_action_id, gallery_name, vote_count, vote_sum, data, created_at, updated_at) 
                          VALUES (#{new_cache_version}, #{vote['call_to_action_id'].to_i}, #{gallery_name}, #{vote['count']}, #{vote['sum']}, '#{hash.to_json}', now(), now())")

    # In order to avoid database stressing, the loop will sleep for 1 second every 1000 lines inserted into cache_votes table
    if i % 500 == 0 and i != 0
      sleep(1)
    end

  end

  if cache["max"].nil?
    execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_versions (name, version, created_at, updated_at) 
                          VALUES ('votes-chart', #{new_cache_version}, now(), now())")
  else
    execute_query(conn, "UPDATE #{tenant + '.' if tenant}cache_versions 
                          SET version = #{new_cache_version}, created_at = now(), updated_at = now() WHERE name = 'votes-chart'")
  end

  logger.info "cache votes successfully updated to version #{new_cache_version}: #{Time.now - start_time}"

end

def execute_job(logger)
  begin
    yield
  rescue Interrupt => exception
    exit
  rescue Exception => exception
    logger.error("exception in main loop: #{exception} - #{exception.backtrace[0, 5]}")
  end
end

def execute_query(connection, query)
  connection.exec(query)        
end

def nullify_or_escape_string(conn, str)
  if str.nil?
    "NULL"
  else
    conn.escape_string(str)
  end
end

Signal.trap("TERM") {
  logger.info("got SIGTERM, exiting")
  exit
}

main()