require 'yaml'
require 'json'
require 'pg'
require 'logger'

def help_message
  <<-EOF
  Usage: #{$0} <configuration_file_path>
  EOF
end

$GOT_SIGTERM = false

def main

  if ARGV.count < 1
    puts help_message
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)
  db_name = config["db_name"]
  tenant = config["tenant"]
  app_root_path = config["app_root_path"]

  conn = PG::Connection.open(:dbname => db_name)
  logger = Logger.new("#{app_root_path}/log/cache_update_medium.log")

  loop do
    execute_job(conn, logger) do
      cache_generate_rankings
    end
  end

  if $GOT_SIGTERM
    logger.info("got SIGTERM, exiting gracefully")
    break
  else
    elapsed_time = Time.now - start_time
    logger.info "Daemon end; elapsed time: #{elapsed_time}s"
    if elapsed_time > 5.minutes
      logger.error("main loop lasted more than 5 minutes; restarting in one minute")
      sleep(1.minutes)
    else
      sleep(5.minutes - elapsed_time)
    end
  end

end

def cache_generate_rankings
  anonymous_user_id = execute_query(conn, "SELECT id FROM #{tenant + '.' if tenant}users WHERE email = 'anonymous@shado.tv'").first["id"]
  rankings = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}rankings")

  rankings.each do |r|

    reward_id = r["reward_id"]
    name = r["name"]

    cache = execute_query(conn, "SELECT version FROM #{tenant + '.' if tenant}cache_versions WHERE name = #{name}").first

    if cache
      execute_query(conn, "DELETE FROM #{tenant + '.' if tenant}cache_rankings WHERE version <> #{cache["version"]}")
      new_cache_version = cache["version"] + 1
    else
      new_cache_version = 1
    end

    period = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}periods WHERE start_datetime < now() AND end_datetime > now() 
                                    AND kind = #{r["period"]}")
    period_id_condition = period.values.blank? ? "ur.period_id is null" : "ur.period_id = #{period.first["id"]}"
    res = execute_query(conn, "SELECT ur.user_id, ur.counter, u.username, u.avatar_selected_url, u.first_name, u.last_name FROM 
                              #{tenant + '.' if tenant}user_rewards ur INNER JOIN #{tenant + '.' if tenant}users u ON u.id = ur.user_id
                              WHERE (ur.reward_id = #{reward_id} and #{period_id_condition} and ur.user_id <> #{anonymous_user_id} ) 
                              ORDER BY ur.counter DESC, ur.updated_at ASC, ur.user_id ASC")

    res.each_with_index do |user_res, i|
      hash = { "username" =>  user_res["username"], "avatar_selected_url" => user_res["avatar_selected_url"], 
                "first_name" => user_res["first_name"], "last_name" => user_res["last_name"], "counter" => user_res["counter"] }
      execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_rankings (name, version, user_id, position, data) 
                            VALUES (#{name}, #{new_cache_version}, #{user_res['user_id']}, #{i + 1}, #{hash.to_json})")
    end

    hash = { "total" => res.count }
    if cache
      execute_query(conn, "UPDATE #{tenant + '.' if tenant}cache_version SET version = #{ new_cache_version } WHERE name = #{name}")
    else
      execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_version (name, version, data) 
                            VALUES (#{ new_cache_version }, #{name}, #{hash.to_json})")
    end

  end

end

def execute_job(conn, logger)
  begin
    logger.info "Daemon start"
    event_logs_path = "#{app_root_path}/log/events"
    start_time = Time.now
    begin
      yield
    rescue Exception => exception
      logger.error("exception in main loop: #{exception} - #{exception.backtrace[0, 5]}")
    end
  rescue Exception => exception
    logger.error("exception in main loop: #{exception} - #{exception.backtrace[0, 5]}")
  end
end

def execute_query(connection, query)
  begin
    connection.execute(query)        
  rescue Exception => exception
    connection.execute("ROLLBACK;")
    raise
  end
end

Signal.trap("TERM") {
  $GOT_SIGTERM = true
}

main()