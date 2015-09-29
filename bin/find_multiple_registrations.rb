require "pg"
require "yaml"
require "json"
require "aws/ses"
require "active_support/time"

def main

  if ARGV.size != 1
    puts <<-EOF
      Usage: #{$0} <config.yml>
    EOF
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)
  tenant = config["tenant"]

  conn = PG::Connection.open(config["production_db"])
  events_conn = PG::Connection.open(config["events_db"])

  rails_app_dir = config["rails_app_dir"]

  ses, mail_from = configure_ses(rails_app_dir, config)
  mail_to = config["to"]
  mail_subject = config["subject"]

  conn.exec("SET search_path TO '#{tenant}';") if tenant

  logger = Logger.new("#{rails_app_dir}/log/find_multiple_registrations.log")

  if config["starting_date"]
    if config["starting_date"] == "today"
      chunk_starting_date = DateTime.now.utc.beginning_of_day
    else
      chunk_starting_date = DateTime.parse(config["starting_date"])
    end
  else
    logger.info("retrieving instantwin start date...")

    instantwin = exec_query(conn, tenant, true, 
      "SELECT valid_from, valid_to FROM call_to_actions WHERE id IN (
        SELECT call_to_action_id FROM interactions WHERE resource_type = 'InstantwinInteraction'
      );"
    ).first
    instantwin_start_date = DateTime.parse(instantwin["valid_from"])

    logger.info("instantwin start date retrieved (#{instantwin_start_date.strftime("%d/%m/%Y")})")

    chunk_starting_date = instantwin_start_date.beginning_of_day
  end

  ending_date = DateTime.now

  if config["registrations_limit"]
    registrations_limit = config["registrations_limit"].to_i
  else 
    registrations_limit = 10
  end

  session_ip_hash = {}
  messages = []

  # Loop
  while chunk_starting_date <= ending_date do

    chunk_ending_date = chunk_starting_date + 1.day

    start_time = Time.now
    logger.info("retrieving logs info for #{chunk_starting_date.strftime("%d/%m/%Y")} ...")

    http_request_start_logs = exec_query(events_conn, tenant, false, 
      "SELECT distinct session_id, timestamp, data->>'remote_ip' AS remote_ip 
      FROM events
      WHERE timestamp >= '#{chunk_starting_date}' 
      AND timestamp < '#{chunk_ending_date}' 
      AND tenant = '#{tenant}' 
      AND message = 'http request start'  
      ORDER BY timestamp;"
    )

    registration_logs = exec_query(events_conn, tenant, false, 
      "SELECT session_id, timestamp, data 
      FROM events
      WHERE timestamp >= '#{chunk_starting_date}' 
      AND timestamp < '#{chunk_ending_date}' 
      AND tenant = '#{tenant}' 
      AND message = 'registration completion' 
      ORDER BY timestamp;"
    )

    logger.info("logs info retrieved")

    logger.info("filling hashes to compare...")

    registration_completion_logs_info = {}
    http_request_start_logs_info = {}

    registration_logs.each do |registration_log|
      registration_completion_logs_info[registration_log["session_id"]] = (registration_completion_logs_info[registration_log["session_id"]] || []) << registration_log["timestamp"]
    end

    http_request_start_logs.each do |http_request_start_log|
      http_request_start_logs_info[http_request_start_log["session_id"]] = (http_request_start_logs_info[http_request_start_log["session_id"]] || {}).merge(http_request_start_log["timestamp"] => http_request_start_log["remote_ip"])
    end

    logger.info("hashes generated")

    logger.info("checking for same ip registrations...")

    ip_registrations_hash = {}
    registration_completion_logs_info.each do |session_id, registration_timestamps_array|
      http_requests_for_session = http_request_start_logs_info[session_id]
      if http_requests_for_session
        registration_timestamps_array.each do |registration_timestamp| 
          ip = get_registration_ip(http_requests_for_session, registration_timestamp)
          if ip
            ip_registrations_hash[ip] = (ip_registrations_hash[ip] || 0) + 1
          end
        end
      end
    end

    ip_registrations_hash.select{ |ip, count| count >= registrations_limit }.each do |ip, count|
      alert_message = "ip #{ip} registered #{count} times"
      logger.info(alert_message)
      messages << alert_message
    end

    logger.info("same ip registrations check for #{chunk_starting_date.strftime("%d/%m/%Y")} end in #{Time.now - start_time} seconds")

    chunk_starting_date = chunk_ending_date

  end

  if messages.any?
    body = "<ul><li>" + messages.map {|s| s.gsub("\n", "<br>\n")}.join("\n</li><li>")  + "</li></ul>"
    send_email(ses, mail_from, mail_to, mail_subject, body)
  end

  logger.info("registrations check process end")

end

def get_registration_ip(http_requests_for_session, registration_timestamp)
  ip = nil
  http_requests_for_session.each do |request_timestamp, request_ip|
    if request_timestamp < registration_timestamp
      ip = request_ip
    end
  end
  return ip
end

def exec_query(conn, tenant, is_db_production, query)
  if !is_db_production
    where_index = query =~ /where/i
    if where_index
      query = query.insert(where_index + 5, " tenant = '#{tenant}' AND")
    else
      query = query.gsub(";", "") + " WHERE tenant = '#{tenant}';"
    end
  end
  conn.exec(query)
end

def configure_ses(rails_app_dir, config)
  ses = AWS::SES::Base.new(
    :access_key_id     => config['ses'][:access_key_id], 
    :secret_access_key => config['ses'][:secret_access_key]
  )
  [ses, config['default_from']]
end

def send_email(ses, from, to, subject, body)
  ses.send_email(
    :to        => to.split(","),
    :source    => from,
    :subject   => subject,
    :html_body => body
  )
end

main()