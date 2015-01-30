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
  tenant = config["tenant"]
  app_root_path = config["app_root_path"]

  logger = Logger.new("#{app_root_path}/log/cache_update_daemon.log")

  conn = PG::Connection.open(db)

  logger.info "cache daemon starting"

  loop do
    start_time = Time.now

    execute_job(logger) do
      cache_generate_rankings(conn, tenant, logger)
    end

    elapsed_time = Time.now - start_time
    logger.info "jobs executed; elapsed time: #{elapsed_time}s"
    sleep(60) # 1 min
  end

end

def cache_generate_rankings(conn, tenant, logger)
  anonymous_user_id = execute_query(conn, "SELECT id FROM #{tenant + '.' if tenant}users WHERE email = 'anonymous@shado.tv'").first["id"]
  rankings = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}rankings")

  rankings.each do |r|
    start_time = Time.now

    reward_id = r["reward_id"]
    name = r["name"]

    cache = execute_query(conn, "SELECT max(version) FROM #{tenant + '.' if tenant}cache_versions WHERE name = '#{name}'").first

    if cache
      cache_version = cache["max"].to_i
      new_cache_version = cache["max"].to_i + 1
      result = execute_query(conn, "DELETE FROM #{tenant + '.' if tenant}cache_rankings WHERE name = '#{name}' AND version <> #{cache_version}")
      if result.cmd_tuples > 0
        logger.info "cache rankings with name #{name} and version != #{cache_version} deleted (#{result.cmd_tuples} rows)"
      end
    else
      new_cache_version = 1
    end

    period = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}periods WHERE start_datetime < now() AND end_datetime > now() 
                                    AND kind = '#{r["period"]}'")
    period_id_condition = period.values.empty? ? "ur.period_id is null" : "ur.period_id = #{period.first["id"]}"
    res = execute_query(conn, "SELECT ur.user_id, ur.counter, u.username, u.avatar_selected_url, u.first_name, u.last_name FROM 
                              #{tenant + '.' if tenant}user_rewards ur INNER JOIN #{tenant + '.' if tenant}users u ON u.id = ur.user_id
                              WHERE (ur.reward_id = #{reward_id} and #{period_id_condition} and ur.user_id <> #{anonymous_user_id} ) 
                              ORDER BY ur.counter DESC, ur.updated_at ASC, ur.user_id ASC")

    res.each_with_index do |user_res, i|
      hash = { "username" =>  nullify_or_escape_string(conn, user_res["username"]), "avatar_selected_url" => user_res["avatar_selected_url"], 
                "first_name" => nullify_or_escape_string(conn, user_res["first_name"]), "last_name" => nullify_or_escape_string(conn, user_res["last_name"]), "counter" => user_res["counter"].to_i }
      execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_rankings (name, version, user_id, position, data, created_at, updated_at) 
                            VALUES ('#{name}', #{new_cache_version}, #{user_res['user_id']}, #{i + 1}, '#{hash.to_json}', now(), now())")
      # In order to avoid database stressing, the loop will sleep for 1 second every 1000 lines inserted into cache_rankings table
      if i % 1000 == 0 and i != 0
        sleep(1)
      end

    end

    hash = { "total" => res.count }
    if cache
      execute_query(conn, "UPDATE #{tenant + '.' if tenant}cache_versions 
                            SET version = #{new_cache_version}, created_at = now(), updated_at = now() WHERE name = '#{name}'")
    else
      execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_versions (name, version, data, created_at, updated_at) 
                            VALUES ('#{name}', #{new_cache_version}, '#{hash.to_json}', now(), now())")
    end

    logger.info "cache ranking for #{name} successfully updated to version #{new_cache_version}: #{Time.now - start_time}"

  end

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