require "pg"
require "yaml"
require "json"
require "aws/ses"
require "active_support/time"

def main

  if ARGV.size != 1
    puts <<-EOF
      Usage: #{$0} <config.yml>
      config.yml file must define "db", "tenant", "events_is_tenant_specific", "rails_app_dir", "to" and "subject" values
    EOF
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)
  tenant = config["tenant"]
  events_is_tenant_specific = config["events_is_tenant_specific"]
  day_to_analyze = config["day_to_analyze"]

  conn = PG::Connection.open(config["production_db"])
  if events_is_tenant_specific
    events_conn = conn
  else
    events_conn = PG::Connection.open(config["events_db"])
  end

  conn.exec("SET search_path TO '#{tenant}';") if tenant

  rails_app_dir = config["rails_app_dir"]
  ses, mail_from = configure_ses(rails_app_dir, config)
  mail_to = config["to"]
  mail_subject = config["subject"]

  errors = []

  if day_to_analyze
    today = DateTime.parse(day_to_analyze).at_end_of_day
  else
    today = DateTime.now.utc
  end

  instantwins = exec_query(conn, tenant, events_is_tenant_specific, true, "SELECT * FROM instantwins WHERE valid_from <= '#{today}';")
  instantwins_map = {}
  instantwins.each do |instantwin|
    instantwins_map[instantwin["id"]] = instantwin
  end

  start_time = Time.now

  puts "#{Time.now} - Instantwin log analyzer starting. #{instantwins.count} total instantwins to analyze"
  puts "\n#{Time.now} - Check that the right user won instantwin when he tried, if any"

  instantwins_map.each do |instantwin_id, instantwin|

    interaction_id = exec_query(conn, tenant, events_is_tenant_specific, true, "SELECT id FROM interactions WHERE resource_type = 'InstantwinInteraction' AND resource_id IN (
      SELECT instantwin_interaction_id FROM instantwins where id = #{instantwin_id});").first["id"].to_i

    instantwin_valid_from = DateTime.parse(instantwin["valid_from"])
    instantwin_valid_to = DateTime.parse(instantwin["valid_to"])

    # Check that the right user won instantwin when he tried, if any
    user_that_should_have_won = exec_query(events_conn, tenant, events_is_tenant_specific, false, 
      "SELECT * FROM events 
      WHERE timestamp >= '#{instantwin["valid_from"]}' 
      AND message = 'instant win attempted' 
      AND (data::json->>'interaction_id')::int = #{interaction_id} 
      ORDER BY timestamp;"
    ).first

    if user_that_should_have_won
      user_id_that_should_have_won = user_that_should_have_won["user_id"]

      win_entry_event = exec_query(events_conn, tenant, events_is_tenant_specific, false, 
        "SELECT * FROM events 
        WHERE timestamp >= '#{instantwin["valid_from"]}' 
        AND timestamp <= '#{instantwin["valid_to"]}' 
        AND message = 'assigning instant win to user' 
        AND (data::json->>'interaction_id')::int = #{interaction_id};"
      ).first

      if win_entry_event.nil?
        message = "ERROR: user #{user_id_that_should_have_won} should have won instantwin #{instantwin_id}, but nobody did"
        puts message
        errors << message
      elsif win_entry_event["user_id"] != user_id_that_should_have_won
        message = "ERROR: first user playing for interaction #{interaction_id} is user #{user_id_that_should_have_won}; 
                    he should have won instantwin #{instantwin_id}, but he did not.\nUser that won is #{win_entry_event["user_id"]}"
        puts message
        errors << message
      end
    end

  end

  # BRAUN SPECIFIC

  if config["tenant"] == "braun_ic"

    credits_assigned = exec_query(events_conn, tenant, events_is_tenant_specific, false, 
      "SELECT user_id, COUNT(*) FROM events WHERE 
      message = 'assigning reward to user' 
      AND (data::json->'outcome_rewards'->>'credit')::int = 1 
      GROUP BY user_id;"
    ).to_a

    credits_assigned_today = exec_query(events_conn, tenant, events_is_tenant_specific, false, 
      "SELECT user_id, (data::json->>'interaction')::int as interaction, COUNT(*) 
      FROM events 
      WHERE timestamp BETWEEN '#{today.beginning_of_day}' AND '#{today.end_of_day}' 
      AND message = 'assigning reward to user' 
      AND (data::json->'outcome_rewards'->>'credit')::int = 1 
      GROUP BY user_id, (data::json->>'interaction')::int;"
    ).to_a

    # Check that no one got more than one credit today
    puts "\n#{Time.now} - Check credits assignment"

    more_than_one_credit_assigned = credits_assigned_today.to_a.select { |credits| credits["count"].to_i > 1 }
    if more_than_one_credit_assigned.any?
      message = "ERROR: On day #{today.strftime("%Y-%m-%d")} more than one credit has been assigned to the following users:"
      more_than_one_credit_assigned.each do |assigned|
        message += "\n user #{assigned["user_id"]} got #{assigned["count"]} credits"
      end
      puts message
      errors << message
    end

    # Check that users have not played more than they could afford
    puts "\n#{Time.now} - Check that number of attempts is less or equal credits gained"

    instantwin_attempts = exec_query(events_conn, tenant, events_is_tenant_specific, false, 
      "SELECT user_id, COUNT(*) FROM events WHERE 
      message = 'instant win attempted' 
      GROUP BY user_id;"
    )

    instantwin_attempts_map = {}
    instantwin_attempts.each do |attempt|
      instantwin_attempts_map[attempt["user_id"].to_i] = attempt["count"].to_i
    end

    credits_assigned.each do |assigned|
      number_of_attempts = instantwin_attempts_map[assigned["user_id"].to_i].to_i
      if number_of_attempts
        if assigned["count"].to_i < number_of_attempts
          message = "ERROR: user #{assigned["user_id"]} gained #{assigned["count"]} credits, but played #{number_of_attempts} times"
          puts message
          errors << message
        end
      end
    end

    # Check that there is one win for day
    puts "\n#{Time.now} - Check that there is one win for day"

    instantwin = exec_query(conn, tenant, events_is_tenant_specific, true, 
      "SELECT valid_from, valid_to FROM call_to_actions WHERE id IN (
        SELECT call_to_action_id FROM interactions WHERE resource_type = 'InstantwinInteraction'
      );"
    ).first
    instantwin_start_date = DateTime.parse(instantwin["valid_from"])
    instantwin_end_date = DateTime.parse(instantwin["valid_to"])

    from = instantwin_start_date.beginning_of_day
    while from < [instantwin_end_date, DateTime.now.utc].min
      wins = exec_query(events_conn, tenant, events_is_tenant_specific, false, 
        "SELECT COUNT(*) FROM events WHERE
        timestamp BETWEEN '#{from}' AND '#{from.end_of_day}' 
        AND message = 'assigning instant win to user';"
      ).first["count"].to_i
      if wins == 0
        puts "ALERT: there are no winnings for day #{from.strftime('%d/%m/%Y')}"
      elsif wins > 1
        message = "ERROR: there are #{wins} winnings for day #{from.strftime('%d/%m/%Y')}"
        puts message
        errors << message
      end
      from = from + 1.day
    end

    win_events = exec_query(events_conn, tenant, events_is_tenant_specific, false, 
      "SELECT * FROM events WHERE message = 'assigning instant win to user';"
      ).to_a

    # Check that every instantwin has been won at most once
    puts "\n#{Time.now} - Check that every instantwin has been won at most once"

    instantwin_id_won_times_map = {}
    win_events.each do |win_event|
      data = JSON.parse(win_event["data"])
      instantwin_id_won_times_map[data["instantwin_id"].to_i] = (instantwin_id_won_times_map[data["instantwin_id"].to_i].to_i || 0) + 1
    end
    instantwin_id_won_times_map.each do |instantwin_id, won_times|
      if won_times > 1
        message = "ERROR: instantwin #{instantwin_id} has been won #{won_times} times"
        puts message
        errors << message
      end
    end

    # Check that winners are major
    puts "\n#{Time.now} - Check winners' age"

    users_winning_ids = Set.new
    win_events.each do |win_event|
      users_winning_ids << win_event["user_id"].to_i
    end
    if users_winning_ids.any?
      winners = exec_query(conn, tenant, events_is_tenant_specific, true, 
        "SELECT * FROM users WHERE id IN (#{users_winning_ids.to_a.join(',')}) ORDER BY birth_date DESC"
      )
      winners.each do |winner|
        if winner["birth_date"]
          if DateTime.parse(winner["birth_date"]) + 18.years > instantwin_start_date
            message = "ERROR: user #{winner["id"]} has won, but he has birth date '#{winner["birth_date"]}'"
            puts message
            errors << message
          end
        else
          message = "ERROR: user #{winner["id"]} has birth_date nil"
          puts message
          errors << message
        end
      end

      # Check that win events did not happen before instantwin valid_from
      puts "\n#{Time.now} - Check that win events did not happen before instantwin valid_from"

      win_events.each do |win|
        instantwin_id = JSON.parse(win["data"])["instantwin_id"]
        instantwin = exec_query(conn, tenant, events_is_tenant_specific, true, 
          "SELECT valid_from FROM instantwins WHERE id = #{instantwin_id};"
        ).first
        if instantwin
          valid_from = instantwin["valid_from"]
          if DateTime.parse(win["timestamp"]) < DateTime.parse(valid_from)
            message = "ERROR: a win occurred before instantwin valid_from time: \nwin: #{win} \ninstantwin valid_from: #{valid_from}"
            puts message
            errors << message
          end
        else
          puts "ALERT: instantwin with id #{instantwin_id} not found"
        end
      end
    end

  end

  if errors.any?
    body = "<ul><li>" + errors.map {|s| s.gsub("\n", "<br>\n")}.join("\n</li><li>")  + "</li></ul>"
    send_email(ses, mail_from, mail_to, mail_subject, body) 
  end

  puts "\n#{Time.now} - Instantwin log analyzer ended in #{Time.now - start_time} seconds"

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
    :to        => to.split(','),
    :source    => from,
    :subject   => subject,
    :html_body => body
  )
end

def exec_query(conn, tenant, events_is_tenant_specific, is_db_production, query)
  if events_is_tenant_specific || is_db_production
    puts query
    conn.exec(query)
  else
    where_index = query =~ /where/i
    if where_index
      query = query.insert(where_index + 5, " tenant = '#{tenant}' AND")
      puts query
      conn.exec(query)
    else
      query = query.gsub(";", "") + " WHERE tenant = '#{tenant}';"
      puts query
      conn.exec(query)
    end
  end
end

main()
