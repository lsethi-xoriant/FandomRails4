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
  host = config["host"]
  user = config["user"]
  password = config["password"]
  tenant = config["tenant"]
  app_root_path = config["app_root_path"]

  if !host
    conn = PG::Connection.open(:dbname => db_name)
  elsif !user or !password
    conn = PG::Connection.open(:host => host, :dbname => db_name)
  else
    conn = PG::Connection.open(:host => host, :dbname => db_name, :user => user, :password => password)
  end
  logger = Logger.new("#{app_root_path}/log/cache_update_daemon.log")

  loop do
    start_time = Time.now
    execute_job(logger) do
      cache_generate_rankings(conn, tenant, logger)
    end

    if $GOT_SIGTERM
      logger.info("got SIGTERM, exiting gracefully")
      break
    else
      elapsed_time = Time.now - start_time
      logger.info "Daemon end; elapsed time: #{elapsed_time}s"
      if elapsed_time > 300 # 5 mins
        logger.error("main loop lasted more than 5 minutes; restarting in one minute")
        sleep(60) # 1 min
      else
        sleep(300 - elapsed_time) # 5 mins - elapsed_time
      end
    end

  end

end

def cache_generate_rankings(conn, tenant, logger)
  anonymous_user_id = execute_query(conn, "SELECT id FROM #{tenant + '.' if tenant}users WHERE email = 'anonymous@shado.tv'").first["id"]
  rankings = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}rankings")

  rankings.each do |r|

    reward_id = r["reward_id"]
    name = r["name"]

    cache = execute_query(conn, "SELECT version FROM #{tenant + '.' if tenant}cache_versions WHERE name = '#{name}'").first

    if cache
      new_cache_version = cache["version"].to_i + 1
      execute_query(conn, "DELETE FROM #{tenant + '.' if tenant}cache_rankings WHERE name = '#{name}' AND version <> #{new_cache_version}")
      logger.info "Cache rankings with name #{name} and version != #{new_cache_version} deleted"
      logger.info "Cache version updating for #{name} from #{new_cache_version - 1} to #{new_cache_version}..."
    else
      new_cache_version = 1
      logger.info "Cache version 1 will be created for #{name}"
    end

    period = execute_query(conn, "SELECT * FROM #{tenant + '.' if tenant}periods WHERE start_datetime < now() AND end_datetime > now() 
                                    AND kind = '#{r["period"]}'")
    period_id_condition = period.values.empty? ? "ur.period_id is null" : "ur.period_id = #{period.first["id"]}"
    res = execute_query(conn, "SELECT ur.user_id, ur.counter, u.username, u.avatar_selected_url, u.first_name, u.last_name FROM 
                              #{tenant + '.' if tenant}user_rewards ur INNER JOIN #{tenant + '.' if tenant}users u ON u.id = ur.user_id
                              WHERE (ur.reward_id = #{reward_id} and #{period_id_condition} and ur.user_id <> #{anonymous_user_id} ) 
                              ORDER BY ur.counter DESC, ur.updated_at ASC, ur.user_id ASC")

    res.each_with_index do |user_res, i|
      hash = { "username" =>  user_res["username"], "avatar_selected_url" => user_res["avatar_selected_url"], 
                "first_name" => user_res["first_name"], "last_name" => user_res["last_name"], "counter" => user_res["counter"].to_i }
      execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_rankings (name, version, user_id, position, data, created_at, updated_at) 
                            VALUES ('#{name}', #{new_cache_version}, #{user_res['user_id']}, #{i + 1}, '#{hash.to_json}', now(), now())")
    end

    logger.info "Cache ranking for #{name} successfully updated to version #{new_cache_version}"

    hash = { "total" => res.count }
    if cache
      execute_query(conn, "UPDATE #{tenant + '.' if tenant}cache_versions SET version = #{new_cache_version} WHERE name = '#{name}'")
    else
      execute_query(conn, "INSERT INTO #{tenant + '.' if tenant}cache_versions (name, version, data, created_at, updated_at) 
                            VALUES ('#{name}', #{new_cache_version}, '#{hash.to_json}', now(), now())")
    end

    logger.info "Cache version successfully updated to version #{new_cache_version}"

  end

end

def execute_job(logger)
  begin
    logger.info "Daemon start"
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
    connection.exec(query)        
  rescue Exception => exception
    connection.exec("ROLLBACK;")
    raise
  end
end

Signal.trap("TERM") {
  $GOT_SIGTERM = true
}

main()