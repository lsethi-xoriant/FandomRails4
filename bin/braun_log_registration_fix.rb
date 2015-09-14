require "pg"
require "yaml"
require "json"
require "fileutils"

def main

  if ARGV.size != 1
    puts <<-EOF
      Usage: #{$0} <config.yml>
    EOF
    exit
  end

  start_time = Time.now
  puts "#{start_time} - Braun logs fix started"

  config = YAML.load_file(ARGV[0].to_s)
  conn = PG::Connection.open(config["production_db"])
  events_conn = PG::Connection.open(config["events_db"])
  conn.exec("SET search_path TO '#{config['tenant']}'") if config["tenant"]
  user_ids = config["user_ids"]
  path_to_file = config["path_to_file"]

  puts "#{Time.now} - Getting users to fix"
  users = conn.exec("SELECT * FROM users WHERE id IN (#{user_ids});")
  puts "#{users.count} users found to fix"

  puts "#{Time.now} - Getting data for users from events table"
  users_data_map = {}
  events_conn.exec(
    "SELECT DISTINCT ON (1) user_id, data 
    FROM events
    WHERE timestamp > '2015-09-01' 
    AND tenant = '#{config["tenant"]}' 
    AND message = 'http request start' 
    AND user_id IN (#{user_ids});"
  ).each do |event|
    users_data_map[event["user_id"]] = JSON.parse(event["data"])
  end
  puts "#{users_data_map.count} data for users found"

  puts "#{Time.now} - Starting files generation"

  users.each_with_index do |user, index|

    session_id = (1..32).map { ["a","b","c","d","e","f",0,1,2,3,4,5,6,7,8,9].sample }.join
    user_data = users_data_map[user["id"]]
    if user_data.nil?
      puts "No data for user #{user['id']}"
      pid = 27601
      remote_ip = "2.228.97.250"
      app_server = "ip-172-31-11-221"
    else
      pid = user_data["pid"] # 12345
      remote_ip = user_data["remote_ip"] # "123.456.7.8"
      app_server = user_data["app_server"] # "ip-172-31-11-221"
    end

    created_at = DateTime.parse(user["created_at"], "%Y-%m-%d %H:%M:%S.%3N")

    http_req_start_time = add_ms(created_at, -89)
    email_sent_time = add_ms(created_at, 567)
    registration_time = add_ms(created_at, 569)
    assigning_reward_time = add_ms(created_at, 574)    
    http_req_end_time = add_ms(created_at, 575)

    http_request_start = {
      "message" => "http request start",
      "level" => "info",
      "data" => {
        "request_uri" => "/users",
        "method" => "POST",
        "http_referer" => "http://www.wellnessmachine.it/",
        "user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
        "lang" => "en-US,en;q=0.8,it-IT;q=0.6,it;q=0.4",
        "app_server" => app_server,
        "session_id" => "#{session_id}",
        "remote_ip" => "#{remote_ip}",
        "tenant" => "braun_ic",
        "user_id" => -1,
        "pid" => pid
      },
      "timestamp" => http_req_start_time,
      "pid" => pid
    }

    email_sent = {
      "message" => "email sent",
      "level" => "info",
      "data" => {
        "data" => nil
      },
      "timestamp"=> email_sent_time,
      "pid" => pid
    }

    registration = {
      "message" => "registration",
      "level" => "audit",
      "data" => {
        "form_data" => {
          "email" => user["email"],
          "privacy" => "1"
        },
        "user_id"=> user["id"]
      },
      "timestamp" => registration_time,
      "pid" => pid
    }


    assigning_reward_to_user = {
      "message" => "assigning reward to user",
      "level" => "audit",
      "data" => {
        "time" => 0.036126036,
        "interaction" => 74,
        "outcome_rewards" => {
          "credit" => 1
        },
        "outcome_unlocks" => [],
        "already_synced" => true
      },
      "timestamp" => assigning_reward_time,
      "pid" => pid
    }


    http_request_end = {
      "message" => "http request end",
      "level" => "info",
      "data" => {
        "request_uri" => "/users",
        "method" => "POST",
        "http_referer" => "http://www.wellnessmachine.it/",
        "user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
        "lang" => "en-US,en;q=0.8,it-IT;q=0.6,it;q=0.4",
        "app_server" => app_server,
        "session_id" => session_id,
        "remote_ip" => remote_ip,
        "tenant" => "braun_ic",
        "user_id" => -1,
        "pid" => pid,
        "status" => 302,
        "cache_hits" => 3,
        "cache_misses" => 0,
        "db_time" => 0.0035624769999999997,
        "view_time" => 0.0,
        "time" => "0.856805299"
      },
      "timestamp" => http_req_end_time,
      "pid" => pid
    }

    file_name = "#{path_to_file}/#{pid}-#{created_at.strftime("%Y%m%d_%H%M%S")}_#{rand(1000000000)}-closed.log"

    File.open(file_name, "w") do |f| 
      f.truncate(0)
      f.write(http_request_start.to_json + "\n")
      f.write(email_sent.to_json + "\n")
      f.write(registration.to_json + "\n")
      f.write(assigning_reward_to_user.to_json + "\n")
      f.write(http_request_end.to_json)
    end

    if (index + 1) % 50 == 0
      puts "#{Time.now} - #{index + 1} files generated"
    end
  end

  puts "#{Time.now} - All files generated. Total time: #{Time.now - start_time} seconds."

end

def add_ms(datetime, ms_delay)
  ms = datetime.strftime("%Q").to_i
  ms += ms_delay
  return DateTime.strptime(ms.to_s, "%Q").strftime("%Y-%m-%d %H:%M:%S.%3N")
end

main()
