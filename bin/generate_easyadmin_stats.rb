require "pg"
require "json"
require "yaml"

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
  tenant_list = config["tenant"].gsub(" ", "").split(",")

  tenant_list.each do |tenant|

    property_tags = get_tags_with_tag(conn, tenant, "property")

    if config["starting_date"]
      starting_date_string = config["starting_date"]
    else
      stats_number = conn.exec("SELECT COUNT(*) FROM #{tenant}.easyadmin_stats").values[0][0].to_i
      if stats_number == 0
        starting_date_string = conn.exec("SELECT MIN(created_at) FROM #{tenant}.users").values[0][0]
      else
        days_shifting = [stats_number, 6].min
        starting_date_string = (Date.parse(conn.exec("SELECT MAX(date) FROM #{tenant}.easyadmin_stats").values[0][0]) - days_shifting).to_s
        puts "Deleting stats for tenant \"#{tenant}\" since #{starting_date_string} in order to recreate them..."
        conn.exec("DELETE FROM #{tenant}.easyadmin_stats where date >= '#{starting_date_string}'")
      end
    end

    reward_cta_ids = conn.exec("SELECT id FROM #{tenant}.rewards WHERE call_to_action_id IS NOT NULL").field_values("id").map(&:to_i)

    starting_date = Date.parse(starting_date_string)

    puts "Starting date: #{starting_date}. \n#{(today - starting_date).to_i} days to iterate. \n"

    if tenant == "disney"

      level_tag_id = conn.exec("SELECT id FROM #{tenant}.tags WHERE name = 'level'").values[0][0]
      badge_tag_id = conn.exec("SELECT id FROM #{tenant}.tags WHERE name = 'badge'").values[0][0]

      level_reward_ids = conn.exec("SELECT reward_id FROM #{tenant}.reward_tags WHERE tag_id = #{level_tag_id}").field_values("reward_id").map(&:to_i)
      badge_reward_ids = conn.exec("SELECT reward_id FROM #{tenant}.reward_tags WHERE tag_id = #{badge_tag_id}").field_values("reward_id").map(&:to_i)
      
      violetta_property_tag_id = conn.exec("SELECT id FROM #{tenant}.tags WHERE name = 'violetta'").values[0][0]
      violetta_cta_ids = conn.exec("SELECT call_to_action_id FROM #{tenant}.call_to_action_tags WHERE tag_id = #{violetta_property_tag_id}").field_values("call_to_action_id").map(&:to_i)
      violetta_interaction_ids = conn.exec("SELECT id FROM #{tenant}.interactions WHERE call_to_action_id IN (#{violetta_cta_ids.join(', ')})").field_values("id").map(&:to_i)
      dc_interaction_ids = conn.exec("SELECT id FROM #{tenant}.interactions WHERE call_to_action_id NOT IN (#{violetta_cta_ids.join(', ')})").field_values("id").map(&:to_i)

      trivia_ids = conn.exec("SELECT id FROM #{tenant}.quizzes WHERE quiz_type = 'TRIVIA'").field_values("id").map(&:to_i)
      versus_ids = conn.exec("SELECT id FROM #{tenant}.quizzes WHERE quiz_type = 'VERSUS'").field_values("id").map(&:to_i)
      trivia_type_interaction_ids = conn.exec("SELECT id FROM #{tenant}.interactions WHERE resource_type = 'Quiz' 
                                                AND resource_id IN (#{trivia_ids.join(', ')})").field_values("id").map(&:to_i)
      versus_type_interaction_ids = conn.exec("SELECT id FROM #{tenant}.interactions WHERE resource_type = 'Quiz' 
                                                AND resource_id IN (#{versus_ids.join(', ')})").field_values("id").map(&:to_i)
      play_type_interaction_ids = type_interaction_ids_array(conn, tenant, "Play")
      like_type_interaction_ids = type_interaction_ids_array(conn, tenant, "Like")
      check_type_interaction_ids = type_interaction_ids_array(conn, tenant, "Check")
      share_type_interaction_ids = type_interaction_ids_array(conn, tenant, "Share")
      download_type_interaction_ids = type_interaction_ids_array(conn, tenant, "Download")
      vote_type_interaction_ids = type_interaction_ids_array(conn, tenant, "Vote")

      dc_reward_ids = conn.exec("SELECT reward_id FROM #{tenant}.reward_tags WHERE tag_id <> #{violetta_property_tag_id}").field_values("reward_id").map(&:to_i)
      violetta_reward_ids = conn.exec("SELECT reward_id FROM #{tenant}.reward_tags WHERE tag_id = #{violetta_property_tag_id}").field_values("reward_id").map(&:to_i)

      dc_level_reward_ids = dc_reward_ids & level_reward_ids
      dc_badges_reward_ids = dc_reward_ids & badge_reward_ids
      violetta_level_reward_ids = violetta_reward_ids & level_reward_ids
      violetta_badges_reward_ids = violetta_reward_ids & badge_reward_ids

      migration_date = Date.parse(conn.exec("SELECT MIN(created_at) FROM #{tenant}.user_rewards WHERE period_id IS NOT NULL").values[0][0])

      if starting_date <= migration_date
        puts "Migration date: #{migration_date}. \nCreating values entry until migration... \n"
        STDOUT.flush

        create_disney_easyadmin_stats_entries(conn, tenant, property_tags, today, dc_interaction_ids, violetta_interaction_ids, level_reward_ids, badge_reward_ids, reward_cta_ids, trivia_type_interaction_ids, versus_type_interaction_ids, play_type_interaction_ids, 
          like_type_interaction_ids, check_type_interaction_ids, share_type_interaction_ids, download_type_interaction_ids, vote_type_interaction_ids, dc_level_reward_ids, dc_badges_reward_ids, violetta_level_reward_ids, violetta_badges_reward_ids, starting_date, migration_date)
        puts "Time elapsed: #{Time.now - start_time}s"
        STDOUT.flush
        starting_date = migration_date
      end
        create_disney_easyadmin_stats_entries(conn, tenant, property_tags, today, dc_interaction_ids, violetta_interaction_ids, level_reward_ids, badge_reward_ids, reward_cta_ids, trivia_type_interaction_ids, versus_type_interaction_ids, play_type_interaction_ids, 
          like_type_interaction_ids, check_type_interaction_ids, share_type_interaction_ids, download_type_interaction_ids, vote_type_interaction_ids, dc_level_reward_ids, dc_badges_reward_ids, violetta_level_reward_ids, violetta_badges_reward_ids, starting_date)

      puts "All easyadmin_stats values created."
      puts "Total time elapsed: #{Time.now - start_time}s"

    else

      create_easyadmin_stats_entries(conn, tenant, property_tags, today, starting_date, reward_cta_ids)

    end

  end

end

def create_easyadmin_stats_entries(conn, tenant, property_tags, today, starting_date, reward_cta_ids)

  return if starting_date >= today
  iteration_time = Time.now

  date_condition = "created_at > '#{starting_date}' AND created_at < '#{starting_date + 1}'"
  puts "Creating entry for #{starting_date}... \n"
  STDOUT.flush

  period_ids = conn.exec(
    "SELECT id FROM #{tenant}.periods WHERE start_datetime > '#{starting_date - 1}' AND end_datetime < '#{starting_date + 2}' AND kind = 'daily'"
  ).field_values("id").map(&:to_i)

  values = {} # set here specific project values
  values = create_values_entry(conn, tenant, property_tags, date_condition, period_ids, reward_cta_ids, values)

  conn.exec("INSERT INTO #{tenant}.easyadmin_stats (date, values, created_at, updated_at) VALUES ('#{starting_date}', '#{values.to_json}', now(), now())")

  puts "Values for #{starting_date} created in #{Time.now - iteration_time}"
  starting_date += 1
  if starting_date.day == 1
    puts "Values for #{starting_date.month - 1}-#{(starting_date - 1).year} created. \n"
    STDOUT.flush
  end
  create_easyadmin_stats_entries(conn, tenant, property_tags, today, starting_date, reward_cta_ids) if (today - starting_date) > 0

end

def create_disney_easyadmin_stats_entries(conn, tenant, property_tags, today, dc_interaction_ids, violetta_interaction_ids, level_reward_ids, badge_reward_ids, reward_cta_ids, trivia_type_interaction_ids, versus_type_interaction_ids, play_type_interaction_ids, 
    like_type_interaction_ids, check_type_interaction_ids, share_type_interaction_ids, download_type_interaction_ids, vote_type_interaction_ids, dc_level_reward_ids, dc_badges_reward_ids, violetta_level_reward_ids, violetta_badges_reward_ids, starting_date, ending_date = nil)

  return if starting_date >= today
  iteration_time = Time.now

  if ending_date.nil?
    date_condition = "created_at > '#{starting_date}' AND created_at < '#{starting_date + 1}'"
    puts "Creating entry for #{starting_date}... \n"
  else
    date_condition = "created_at > '#{starting_date}' AND created_at < '#{ending_date + 1}'"
  end
  STDOUT.flush

  period_ids = ending_date ? nil : conn.exec("SELECT id FROM #{tenant}.periods WHERE start_datetime > '#{starting_date - 1}' 
                                                AND end_datetime < '#{starting_date + 2}' AND kind = 'daily'").field_values("id").map(&:to_i)

  users = conn.exec("SELECT id FROM #{tenant}.users WHERE #{date_condition} AND anonymous_id IS NULL")
  total_users = users.count
  users_ids = users.field_values("id").map(&:to_i)
  social_reg_users = users_ids.empty? ? 0 : conn.exec("SELECT id FROM #{tenant}.authentications WHERE user_id IN (#{users_ids.join(', ')})").count

  total_comments = conn.exec("SELECT id FROM #{tenant}.user_comment_interactions WHERE #{date_condition}").count
  approved_comments = conn.exec("SELECT id FROM #{tenant}.user_comment_interactions WHERE #{date_condition} AND approved = true").count

  dc_trivia, dc_trivia_correct = count_trivia(conn, tenant, date_condition, trivia_type_interaction_ids, dc_interaction_ids)
  violetta_trivia, violetta_trivia_correct = count_trivia(conn, tenant, date_condition, trivia_type_interaction_ids, violetta_interaction_ids)

  dc_assigned_levels, dc_assigned_badges = count_assigned_levels_and_badges(conn, tenant, date_condition, period_ids, dc_level_reward_ids, dc_badges_reward_ids, ending_date)
  violetta_assigned_levels, violetta_assigned_badges = count_assigned_levels_and_badges(conn, tenant, date_condition, period_ids, violetta_level_reward_ids, violetta_badges_reward_ids, ending_date)
  rewards = count_rewards(conn, tenant, reward_cta_ids, date_condition, period_ids)

  values = {
    "total-users" => total_users, 
    "social-reg-users" => social_reg_users, 
    "rewards" => rewards,
    "total-comments" => total_comments, 
    "approved-comments" => approved_comments
  }

  if ending_date
    values = values.merge({ 
      "disney-channel" => { 
        "comment-counter" => count_comments_for_property(conn, tenant, date_condition, violetta_interaction_ids, "disney-channel"),
        "trivia-counter" => dc_trivia, # changed from trivia_answers
        "trivia-correct-counter" => dc_trivia_correct, # changed from trivia_correct_answers
        "versus-counter" => count_user_interactions(conn, tenant, date_condition, versus_type_interaction_ids, dc_interaction_ids),  # changed from versus_answers
        "play-counter" => count_user_interactions(conn, tenant, date_condition, play_type_interaction_ids, dc_interaction_ids, true), # changed from plays
        "like-counter" => count_user_interactions(conn, tenant, date_condition, like_type_interaction_ids, dc_interaction_ids, true), # changed from likes
        "check-counter" => count_user_interactions(conn, tenant, date_condition, check_type_interaction_ids, dc_interaction_ids), # changed from checks
        "share-counter" => count_user_interactions(conn, tenant, date_condition, share_type_interaction_ids, dc_interaction_ids, true), # changed from shares
        "download-counter" => count_user_interactions(conn, tenant, date_condition, download_type_interaction_ids, dc_interaction_ids, true), # changed from downloads
        "vote-counter" => count_user_interactions(conn, tenant, date_condition, vote_type_interaction_ids, dc_interaction_ids), # changed from votes
        "assigned-levels" => dc_assigned_levels, 
        "assigned-badges" => dc_assigned_badges
      }, 

      "violetta" => { 
        "violetta-comment-counter" => count_comments_for_property(conn, tenant, date_condition, violetta_interaction_ids, "violetta"),
        "violetta-trivia-counter" => violetta_trivia, 
        "violetta-trivia-correct-counter" => violetta_trivia_correct, 
        "violetta-versus-counter" => count_user_interactions(conn, tenant, date_condition, versus_type_interaction_ids, violetta_interaction_ids), 
        "violetta-play-counter" => count_user_interactions(conn, tenant, date_condition, play_type_interaction_ids, violetta_interaction_ids, true), 
        "violetta-like-counter" => count_user_interactions(conn, tenant, date_condition, like_type_interaction_ids, violetta_interaction_ids, true), 
        "violetta-check-counter" => count_user_interactions(conn, tenant, date_condition, check_type_interaction_ids, violetta_interaction_ids), 
        "violetta-share-counter" => count_user_interactions(conn, tenant, date_condition, share_type_interaction_ids, violetta_interaction_ids, true), 
        "violetta-download-counter" => count_user_interactions(conn, tenant, date_condition, download_type_interaction_ids, violetta_interaction_ids, true), 
        "violetta-vote-counter" => count_user_interactions(conn, tenant, date_condition, vote_type_interaction_ids, violetta_interaction_ids), 
        "violetta-assigned-levels" => violetta_assigned_levels, 
        "violetta-assigned-badges" => violetta_assigned_badges
      }
    })
  else

    values = create_values_entry(conn, tenant, property_tags, date_condition, period_ids, reward_cta_ids, values)

  end

  values = values.merge({ "migration_day" => true }) if ending_date

  conn.exec("INSERT INTO #{tenant}.easyadmin_stats (date, values, created_at, updated_at) VALUES ('#{ending_date || starting_date}', '#{values.to_json}', now(), now())")

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
    create_disney_easyadmin_stats_entries(conn, tenant, property_tags, today, dc_interaction_ids, violetta_interaction_ids, level_reward_ids, badge_reward_ids, reward_cta_ids, trivia_type_interaction_ids, versus_type_interaction_ids, play_type_interaction_ids, 
      like_type_interaction_ids, check_type_interaction_ids, share_type_interaction_ids, download_type_interaction_ids, vote_type_interaction_ids, dc_level_reward_ids, dc_badges_reward_ids, violetta_level_reward_ids, violetta_badges_reward_ids, starting_date) if (today - starting_date) > 0
  end

end

def count_rewards(conn, tenant, reward_cta_ids, date_condition, period_ids)
  return 0 if reward_cta_ids.empty?
  if period_ids
    if period_ids.any?
      return conn.exec("SELECT id FROM #{tenant}.user_rewards WHERE reward_id IN (#{reward_cta_ids.join(', ')}) AND period_id in(#{period_ids.join(', ')})").count
    end
  end
  return conn.exec("SELECT id FROM #{tenant}.user_rewards WHERE reward_id IN (#{reward_cta_ids.join(', ')}) AND #{date_condition}").count
end

def count_comments_for_property(conn, tenant, date_condition, violetta_interaction_ids, property)
  conn.exec("SELECT id FROM #{tenant}.user_comment_interactions WHERE #{date_condition} AND comment_id IN (
    SELECT resource_id FROM #{tenant}.interactions WHERE resource_type = 'Comment' 
    AND id #{property == 'violetta' ? "" : "NOT "}IN (#{violetta_interaction_ids.join(', ')}))").count
end

def count_trivia(conn, tenant, date_condition, trivia_type_interaction_ids, property_interaction_ids)
  interaction_ids = trivia_type_interaction_ids & property_interaction_ids
  if interaction_ids.empty?
    return 0
  else
    user_interactions = conn.exec("SELECT * FROM #{tenant}.user_interactions WHERE #{date_condition} AND interaction_id IN (#{interaction_ids.join(', ')})")
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

def count_user_interactions(conn, tenant, date_condition, type_interaction_ids, property_interaction_ids, counter = false)
  interaction_ids = type_interaction_ids & property_interaction_ids
  if interaction_ids.empty?
    return 0
  else
    if counter
      return conn.exec("SELECT SUM(counter) FROM #{tenant}.user_interactions WHERE #{date_condition} 
                          AND interaction_id IN (#{interaction_ids.join(', ')})").values[0][0].to_i
    else
      return conn.exec("SELECT * FROM #{tenant}.user_interactions WHERE #{date_condition} 
                        AND interaction_id IN (#{interaction_ids.join(', ')})").count
    end
  end
end

def count_assigned_levels_and_badges(conn, tenant, date_condition, period_ids, property_level_reward_ids, property_badges_reward_ids, before_migration)
  if period_ids.nil? and !before_migration
    return 0, 0
  else
    if period_ids.nil?
      period_condition = "#{date_condition} AND "
    else
      period_condition = period_ids.empty? ? "#{date_condition} AND " : "period_id IN (#{period_ids.join(', ')}) AND "
    end
    return conn.exec("SELECT COUNT(*) FROM #{tenant}.user_rewards WHERE #{period_condition}reward_id IN (#{property_level_reward_ids.join(', ')})").values[0][0].to_i, 
            conn.exec("SELECT COUNT(*) FROM #{tenant}.user_rewards WHERE #{period_condition}reward_id IN (#{property_badges_reward_ids.join(', ')})").values[0][0].to_i
  end
end

def create_values_entry(conn, tenant, property_tags, date_condition, period_ids, reward_cta_ids, values)
  users = conn.exec("SELECT id FROM #{tenant}.users WHERE #{date_condition} AND anonymous_id IS NULL")
  total_users = users.count
  users_ids = users.field_values("id").map(&:to_i)
  social_reg_users = users_ids.empty? ? 0 : conn.exec("SELECT id FROM #{tenant}.authentications WHERE user_id IN (#{users_ids.join(', ')})").count

  total_comments = conn.exec("SELECT id FROM #{tenant}.user_comment_interactions WHERE #{date_condition}").count
  approved_comments = conn.exec("SELECT id FROM #{tenant}.user_comment_interactions WHERE #{date_condition} AND approved = true").count

  rewards = count_rewards(conn, tenant, reward_cta_ids, date_condition, period_ids)

  property_values_hash = {
    "total-users" => total_users, 
    "social-reg-users" => social_reg_users, 
    "rewards" => rewards,
    "total-comments" => total_comments, 
    "approved-comments" => approved_comments
  }

  if property_tags.any?

    property_tags.each do |property_tag|
      counter_rewards = get_rewards_with_tags(conn, tenant, [property_tag["name"], "counter"])
      badge_rewards = get_rewards_with_tags(conn, tenant, [property_tag["name"], "badge"])
      level_rewards = get_rewards_with_tags(conn, tenant, [property_tag["name"], "level"])

      property_values_hash.merge!({ 
        property_tag["name"] => get_property_counters_levels_badges_by_periods(conn, tenant, property_tag["name"], counter_rewards, badge_rewards, level_rewards, period_ids) 
      })
    end

  else

    counter_rewards = get_rewards_with_tags(conn, tenant, ["counter"])
    badge_rewards = get_rewards_with_tags(conn, tenant, ["badge"])
    level_rewards = get_rewards_with_tags(conn, tenant, ["level"])

    property_values_hash.merge!({ 
      "general" => get_property_counters_levels_badges_by_periods(conn, tenant, "general", counter_rewards, badge_rewards, level_rewards, period_ids) 
    })

  end

  values.merge(property_values_hash)
end

def get_tags_with_tag(conn, tenant, tag_name)
  conn.exec("SELECT * FROM #{tenant}.tags WHERE id IN (SELECT tag_id FROM #{tenant}.tags_tags WHERE other_tag_id IN (SELECT id FROM #{tenant}.tags WHERE name = '#{tag_name}'))").to_a
end

def get_rewards_with_tags(conn, tenant, tag_names_array)
  reward_ids = []
  tag_names_array.each_with_index do |tag_name, i|
    ids = []
    conn.exec("SELECT reward_id FROM #{tenant}.reward_tags WHERE tag_id IN (SELECT id FROM #{tenant}.tags WHERE name = '#{tag_name}')").each do |r|
      ids << r.values[0].to_i
    end
    reward_ids = i == 0 ? ids : reward_ids & ids
  end
  reward_ids
end

def get_property_counters_levels_badges_by_periods(conn, tenant, property, property_counter_reward_ids, property_badge_reward_ids, property_level_reward_ids, period_ids)
  counters_hash = {}
  if period_ids.any?
    value = "SUM(counter)"
    period_id_condition = "user_rewards.period_id IN (#{period_ids.join(', ')}) AND"
  else
    value = 0
    period_id_condition = ""
  end

  if property_counter_reward_ids.any?
    conn.exec("SELECT rewards.name, #{value} AS value 
      FROM #{tenant}.user_rewards RIGHT OUTER JOIN #{tenant}.rewards ON reward_id = rewards.id 
      WHERE #{period_id_condition} rewards.id IN (#{property_counter_reward_ids.join(', ')}) 
      GROUP BY rewards.name").to_a.each do |res| counters_hash.merge!({ res["name"] => res["value"].to_i }) end
  end

  if property_badge_reward_ids.any?
    assigned_badges = 0
    assigned_prefix = ["disney-channel", "general"].include?(property) ? "" : "#{property}-"
    conn.exec("SELECT #{value} AS value 
      FROM #{tenant}.user_rewards RIGHT OUTER JOIN #{tenant}.rewards ON reward_id = rewards.id 
      WHERE #{period_id_condition} rewards.id IN (#{property_badge_reward_ids.join(', ')}) 
      GROUP BY rewards.name").to_a.each do |res| assigned_badges += res["value"].to_i end
    counters_hash.merge!({ "#{assigned_prefix}assigned-badges" => assigned_badges })
  end

  if property_level_reward_ids.any?
    assigned_levels = 0
    conn.exec("SELECT #{value} AS value 
      FROM #{tenant}.user_rewards RIGHT OUTER JOIN #{tenant}.rewards ON reward_id = rewards.id 
      WHERE #{period_id_condition} rewards.id IN (#{property_level_reward_ids.join(', ')}) 
      GROUP BY rewards.name").to_a.each do |res| assigned_levels += res["value"].to_i end
    counters_hash.merge!({ "#{assigned_prefix}assigned-levels" => assigned_levels })
  end

  counters_hash
end

def get_counter_amount(conn, tenant, period_ids, counter_name)
  conn.exec("SELECT SUM counter FROM #{tenant}.user_rewards WHERE period_id IN(#{period_ids.join(', ')}) AND reward_id IN (SELECT id FROM #{tenant}.rewards WHERE name = '#{counter_name}')").values[0][0].to_i
end

def type_interaction_ids_array(conn, tenant, resource_type)
  conn.exec("SELECT id FROM #{tenant}.interactions WHERE resource_type = '#{resource_type}'").field_values("id").map(&:to_i)
end

main()