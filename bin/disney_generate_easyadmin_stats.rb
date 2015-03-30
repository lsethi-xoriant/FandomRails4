require "pg"
require "json"
require "yaml"
require "ruby-debug"

def main

  if ARGV.size != 1
    puts <<-EOF
      Usage: #{$0} <config.yml>
    EOF
    exit
  end

  start_time = Time.now
  today = Date.today

  config = YAML.load_file(ARGV[0].to_s)
  conn = PG::Connection.open(config["db"])

  level_tag_id = conn.exec("SELECT id FROM disney.tags WHERE name = 'level'").values[0][0]
  badge_tag_id = conn.exec("SELECT id FROM disney.tags WHERE name = 'badge'").values[0][0]

  level_reward_ids = conn.exec("SELECT reward_id FROM disney.reward_tags WHERE tag_id = #{level_tag_id}").field_values("reward_id").map(&:to_i)
  badge_reward_ids = conn.exec("SELECT reward_id FROM disney.reward_tags WHERE tag_id = #{badge_tag_id}").field_values("reward_id").map(&:to_i)
  
  violetta_property_tag_id = conn.exec("SELECT id FROM disney.tags WHERE name = 'violetta'").values[0][0]
  violetta_cta_ids = conn.exec("SELECT call_to_action_id FROM disney.call_to_action_tags WHERE tag_id = #{violetta_property_tag_id}").field_values("call_to_action_id").map(&:to_i)
  violetta_interaction_ids = conn.exec("SELECT id FROM disney.interactions WHERE call_to_action_id IN (#{violetta_cta_ids.join(', ')})").field_values("id").map(&:to_i)
  dc_interaction_ids = conn.exec("SELECT id FROM disney.interactions WHERE call_to_action_id NOT IN (#{violetta_cta_ids.join(', ')})").field_values("id").map(&:to_i)

  reward_cta_ids = conn.exec("SELECT id FROM disney.rewards WHERE call_to_action_id IS NOT NULL").field_values("id").map(&:to_i)

  trivia_ids = conn.exec("SELECT id FROM disney.quizzes WHERE quiz_type = 'TRIVIA'").field_values("id").map(&:to_i)
  versus_ids = conn.exec("SELECT id FROM disney.quizzes WHERE quiz_type = 'VERSUS'").field_values("id").map(&:to_i)
  trivia_type_interaction_ids = conn.exec("SELECT id FROM disney.interactions WHERE resource_type = 'Quiz' 
                                            AND resource_id IN (#{trivia_ids.join(', ')})").field_values("id").map(&:to_i)
  versus_type_interaction_ids = conn.exec("SELECT id FROM disney.interactions WHERE resource_type = 'Quiz' 
                                            AND resource_id IN (#{versus_ids.join(', ')})").field_values("id").map(&:to_i)
  play_type_interaction_ids = type_interaction_ids_array(conn, "Play")
  like_type_interaction_ids = type_interaction_ids_array(conn, "Like")
  check_type_interaction_ids = type_interaction_ids_array(conn, "Check")
  share_type_interaction_ids = type_interaction_ids_array(conn, "Share")
  download_type_interaction_ids = type_interaction_ids_array(conn, "Download")
  vote_type_interaction_ids = type_interaction_ids_array(conn, "Vote")

  dc_reward_ids = conn.exec("SELECT reward_id FROM disney.reward_tags WHERE tag_id <> #{violetta_property_tag_id}").field_values("reward_id").map(&:to_i)
  violetta_reward_ids = conn.exec("SELECT reward_id FROM disney.reward_tags WHERE tag_id = #{violetta_property_tag_id}").field_values("reward_id").map(&:to_i)

  dc_level_reward_ids = dc_reward_ids & level_reward_ids
  dc_badges_reward_ids = dc_reward_ids & badge_reward_ids
  violetta_level_reward_ids = violetta_reward_ids & level_reward_ids
  violetta_badges_reward_ids = violetta_reward_ids & badge_reward_ids

  if config["starting_date"]
    starting_date_string = config["starting_date"]
  else
    if conn.exec("SELECT COUNT(*) FROM disney.easyadmin_stats").values[0][0].to_i == 0
      starting_date_string = conn.exec("SELECT MIN(created_at) FROM disney.users").values[0][0]
    else
      starting_date_string = conn.exec("SELECT MAX(date) FROM disney.easyadmin_stats").values[0][0]
    end
  end
  starting_date = Date.parse(starting_date_string)
  migration_date = Date.parse(conn.exec("SELECT MIN(created_at) FROM disney.user_rewards WHERE period_id IS NOT NULL").values[0][0])

  puts "Starting date: #{starting_date}. \n#{(today - starting_date).to_i - 1} days to iterate. \n"
  if starting_date <= migration_date
    puts "Migration date: #{migration_date}. \nCreating values entry until migration... \n"
    STDOUT.flush

    create_easyadmin_stats_entry(conn, today, dc_interaction_ids, violetta_interaction_ids, level_reward_ids, badge_reward_ids, reward_cta_ids, trivia_type_interaction_ids, versus_type_interaction_ids, play_type_interaction_ids, 
      like_type_interaction_ids, check_type_interaction_ids, share_type_interaction_ids, download_type_interaction_ids, vote_type_interaction_ids, dc_level_reward_ids, dc_badges_reward_ids, violetta_level_reward_ids, violetta_badges_reward_ids, starting_date, migration_date)
    puts "Time elapsed: #{Time.now - start_time}s"
    STDOUT.flush
    starting_date = migration_date
  end
    create_easyadmin_stats_entry(conn, today,  dc_interaction_ids, violetta_interaction_ids, level_reward_ids, badge_reward_ids, reward_cta_ids, trivia_type_interaction_ids, versus_type_interaction_ids, play_type_interaction_ids, 
      like_type_interaction_ids, check_type_interaction_ids, share_type_interaction_ids, download_type_interaction_ids, vote_type_interaction_ids, dc_level_reward_ids, dc_badges_reward_ids, violetta_level_reward_ids, violetta_badges_reward_ids, starting_date + 1)

  puts "All easyadmin_stats values created."
  puts "Total time elapsed: #{Time.now - start_time}s"
end

def create_easyadmin_stats_entry(conn, today, dc_interaction_ids, violetta_interaction_ids, level_reward_ids, badge_reward_ids, reward_cta_ids, trivia_type_interaction_ids, versus_type_interaction_ids, play_type_interaction_ids, 
    like_type_interaction_ids, check_type_interaction_ids, share_type_interaction_ids, download_type_interaction_ids, vote_type_interaction_ids, dc_level_reward_ids, dc_badges_reward_ids, violetta_level_reward_ids, violetta_badges_reward_ids, starting_date, ending_date = nil)
  return if starting_date >= today

  iteration_time = Time.now
  if ending_date.nil?
    date_condition = "created_at > '#{starting_date - 1}' AND created_at < '#{starting_date + 1}'"
    puts "Creating entry for #{starting_date}... \n"
  else
    date_condition = "created_at > '#{starting_date - 1}' AND created_at < '#{ending_date + 1}'"
  end

  users = conn.exec("SELECT id FROM disney.users WHERE #{date_condition}")
  total_users = users.count
  users_ids = users.field_values("id").map(&:to_i)
  social_reg_users = users_ids.empty? ? 0 : conn.exec("SELECT id FROM disney.authentications WHERE user_id IN (#{users_ids.join(', ')})").count

  total_comments = conn.exec("SELECT id FROM disney.user_comment_interactions WHERE #{date_condition}").count
  approved_comments = conn.exec("SELECT id FROM disney.user_comment_interactions WHERE #{date_condition} AND approved = true").count

  dc_trivia, dc_trivia_correct = count_trivia(conn, date_condition, trivia_type_interaction_ids, dc_interaction_ids)
  violetta_trivia, violetta_trivia_correct = count_trivia(conn, date_condition, trivia_type_interaction_ids, violetta_interaction_ids)

  period_ids = ending_date ? nil : conn.exec("SELECT id FROM disney.periods WHERE start_datetime > '#{starting_date - 1}' 
                                                AND end_datetime < '#{starting_date + 2}' AND kind = 'daily'").field_values("id").map(&:to_i)

  dc_assigned_levels, dc_assigned_badges = count_assigned_levels_and_badges(conn, date_condition, period_ids, dc_level_reward_ids, dc_badges_reward_ids, ending_date)
  violetta_assigned_levels, violetta_assigned_badges = count_assigned_levels_and_badges(conn, date_condition, period_ids, violetta_level_reward_ids, violetta_badges_reward_ids, ending_date)
  rewards = count_rewards(conn, reward_cta_ids, date_condition, period_ids)

  values = { 
    "total_users" => total_users, 
    "social_reg_users" => social_reg_users, 
    "rewards" => rewards, 
    "total_comments" => total_comments, 
    "approved_comments" => approved_comments, 

    "disney_channel" => { 
      "trivia_answers" => violetta_trivia, 
      "trivia_correct_answers" => violetta_trivia_correct, 
      "versus_answers" => count_user_interactions(conn, date_condition, versus_type_interaction_ids, dc_interaction_ids), 
      "plays" => count_user_interactions(conn, date_condition, play_type_interaction_ids, dc_interaction_ids, true), 
      "likes" => count_user_interactions(conn, date_condition, like_type_interaction_ids, dc_interaction_ids, true), 
      "checks" => count_user_interactions(conn, date_condition, check_type_interaction_ids, dc_interaction_ids), 
      "shares" => count_user_interactions(conn, date_condition, share_type_interaction_ids, dc_interaction_ids, true), 
      "downloads" => count_user_interactions(conn, date_condition, download_type_interaction_ids, dc_interaction_ids, true), 
      "votes" => count_user_interactions(conn, date_condition, vote_type_interaction_ids, dc_interaction_ids), 
      "assigned_levels" => dc_assigned_levels, 
      "assigned_badges" => dc_assigned_badges 
    }, 

    "violetta" => { 
      "trivia_answers" => dc_trivia, 
      "trivia_correct_answers" => dc_trivia_correct, 
      "versus_answers" => count_user_interactions(conn, date_condition, versus_type_interaction_ids, violetta_interaction_ids), 
      "plays" => count_user_interactions(conn, date_condition, play_type_interaction_ids, violetta_interaction_ids, true), 
      "likes" => count_user_interactions(conn, date_condition, like_type_interaction_ids, violetta_interaction_ids, true), 
      "checks" => count_user_interactions(conn, date_condition, check_type_interaction_ids, violetta_interaction_ids), 
      "shares" => count_user_interactions(conn, date_condition, share_type_interaction_ids, violetta_interaction_ids, true), 
      "downloads" => count_user_interactions(conn, date_condition, download_type_interaction_ids, violetta_interaction_ids, true), 
      "votes" => count_user_interactions(conn, date_condition, vote_type_interaction_ids, violetta_interaction_ids), 
      "assigned_levels" => violetta_assigned_levels, 
      "assigned_badges" => violetta_assigned_badges 
    }
  }

  values = values.merge({ "migration_day" => true }) if ending_date

  conn.exec("INSERT INTO disney.easyadmin_stats (date, values, created_at, updated_at) VALUES ('#{ending_date || starting_date}', '#{values.to_json}', now(), now())")

  if ending_date
    puts "Values until migration date created. \n"
    STDOUT.flush
  else
    puts "Values for #{starting_date} created in #{Time.now - iteration_time}"
    starting_date += 1
    if starting_date.day == 1
      puts "Values for #{starting_date.month - 1}-#{(starting_date - 1).year} created. \n"
      STDOUT.flush
    end
    create_easyadmin_stats_entry(conn, today, dc_interaction_ids, violetta_interaction_ids, level_reward_ids, badge_reward_ids, reward_cta_ids, trivia_type_interaction_ids, versus_type_interaction_ids, play_type_interaction_ids, 
      like_type_interaction_ids, check_type_interaction_ids, share_type_interaction_ids, download_type_interaction_ids, vote_type_interaction_ids, dc_level_reward_ids, dc_badges_reward_ids, violetta_level_reward_ids, violetta_badges_reward_ids, starting_date) if (today - starting_date) > 0
  end

end

def count_rewards(conn, reward_cta_ids, date_condition, period_ids)
  if period_ids
    if period_ids.any?
      return conn.exec("SELECT id FROM disney.user_rewards WHERE reward_id IN (#{reward_cta_ids.join(', ')}) AND period_id in(#{period_ids.join(', ')})").count
    end
  end
  return conn.exec("SELECT id FROM disney.user_rewards WHERE reward_id IN (#{reward_cta_ids.join(', ')}) AND #{date_condition}").count
end

def count_trivia(conn, date_condition, trivia_type_interaction_ids, property_interaction_ids)
  interaction_ids = trivia_type_interaction_ids & property_interaction_ids
  if interaction_ids.empty?
    return 0
  else
    user_interactions = conn.exec("SELECT * FROM disney.user_interactions WHERE #{date_condition} AND interaction_id IN (#{interaction_ids.join(', ')})")
    trivia = user_interactions.count
    trivia_correct = 0
    user_interactions.each do |user_interaction|
      win = JSON.parse(user_interaction["outcome"])["win"]["attributes"]["reward_name_to_counter"]
      correct = JSON.parse(user_interaction["outcome"])["correct_answer"]["attributes"]["reward_name_to_counter"]
      if win["point"] == correct["point"]
        trivia_correct += 1
      end
    end
  end
  return trivia, trivia_correct
end

def count_user_interactions(conn, date_condition, type_interaction_ids, property_interaction_ids, counter = false)
  interaction_ids = type_interaction_ids & property_interaction_ids
  if interaction_ids.empty?
    return 0
  else
    if counter
      return conn.exec("SELECT SUM(counter) FROM disney.user_interactions WHERE #{date_condition} 
                          AND interaction_id IN (#{interaction_ids.join(', ')})").values[0][0].to_i
    else
      return conn.exec("SELECT * FROM disney.user_interactions WHERE #{date_condition} 
                        AND interaction_id IN (#{interaction_ids.join(', ')})").count
    end
  end
end

def count_assigned_levels_and_badges(conn, date_condition, period_ids, property_level_reward_ids, property_badges_reward_ids, before_migration)
  if period_ids.nil? and !before_migration
    return 0, 0
  else
    if period_ids.nil?
      period_condition = "#{date_condition} AND "
    else
      period_condition = period_ids.empty? ? "#{date_condition} AND " : "period_id IN (#{period_ids.join(', ')}) AND "
    end
    return conn.exec("SELECT COUNT(*) FROM disney.user_rewards WHERE #{period_condition}reward_id IN (#{property_level_reward_ids.join(', ')})").values[0][0].to_i, 
            conn.exec("SELECT COUNT(*) FROM disney.user_rewards WHERE #{period_condition}reward_id IN (#{property_badges_reward_ids.join(', ')})").values[0][0].to_i
  end
end

def type_interaction_ids_array(conn, resource_type)
  conn.exec("SELECT id FROM disney.interactions WHERE resource_type = '#{resource_type}'").field_values("id").map(&:to_i)
end

main()