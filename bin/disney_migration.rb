#!/usr/bin/env ruby

require "yaml"
require "pg"
require "json"
require "fileutils"
require "benchmark"
require "ruby-debug"

BIG_NUMBER_OF_LINES = 500000

########## METHOD TO CREATE GALLERY_ID - TAG_ID MAP, IF TAG ALREADY EXISTS IN SEED ##########

def map_category_ids_to_tag_ids(source_db_connection, source_db_tenant, destination_db_connection, destination_db_tenant)
  map = Hash.new
  source_categories_names = Array.new
  source_db_connection.exec("SELECT title FROM cta_categories").values.each do |title|
    source_categories_names << title[0] unless title[0] == "categoriarosa"
  end
  #puts source_categories_names.values
  destination_tags_names = Array.new
  destination_db_connection.exec("SELECT name FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags").values.each do |name|
    destination_tags_names << name[0]
  end

  source_categories_names = gsubs(source_categories_names)
  #destination_tags_names = gsubs(destination_tags_names)

  if (source_categories_names & destination_tags_names).count != source_categories_names.count 
    print_missing("cta_categories", source_categories_names, destination_tags_names)
    exit
  else
    source_categories_names.each do |name|
      category_id = source_db_connection.exec("SELECT id FROM cta_categories where title = '#{ungsub(name)}'").values[0][0]
      tag_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags where name = '#{name}'").values[0][0]
      map[category_id] = tag_id
    end
  end

  categoriarosa_id = source_db_connection.exec("SELECT id FROM cta_categories where title = 'categoriarosa'").values[0]
  tutto_violetta_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags where name = 'tutto-violetta'").values[0]
  map[categoriarosa_id[0]] = tutto_violetta_id[0] if categoriarosa_id

  return map
end

def gsubs(names)
  res = Array.new
  names.each do |name|
    res << name.gsub('_', '-').gsub('mystery', 'mistery')
  end
  res
end

def ungsub(name)
  name.gsub('-', '_').gsub('mistery', 'mystery')
end

########## METHOD TO CREATE CORE_CUSTOM_GALLERY_ID - TAG_ID MAP, IF TAG ALREADY EXISTS IN SEED ##########

def map_core_custom_gallery_ids_to_tag_ids(source_db_connection, source_db_tenant, destination_db_connection, destination_db_tenant)
  map = Hash.new
  source_core_custom_galleries_names = Array.new
  source_db_connection.exec("SELECT name FROM core_custom_galleries").values.each do |name|
    source_core_custom_galleries_names << name[0]
  end
  #puts source_core_custom_galleries_names.values
  destination_tags_names = Array.new
  destination_db_connection.exec("SELECT name FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags").values.each do |name|
    destination_tags_names << name[0]
  end

  if (source_core_custom_galleries_names & destination_tags_names).count != source_core_custom_galleries_names.count 
    print_missing("core_custom_galleries", source_core_custom_galleries_names, destination_tags_names)
    exit
  else
    source_core_custom_galleries_names.each do |name|
      category_id = source_db_connection.exec("SELECT id FROM core_custom_galleries where name = '#{name}'").values[0][0]
      tag_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags where name = '#{name}'").values[0][0]
      map[category_id] = tag_id
    end
  end

  return map
end

def print_missing(table_name, categories, tags)
  puts "Tags missing. \nThere are #{(categories & tags).count} #{table_name} on #{categories.count} total #{table_name}.\n"
  res = Array.new
  puts categories
  puts "\n-----------------------------------\n"
  puts tags
  categories.each do |c|
    res << c unless tags.include?(c)
  end
  puts "Tag mancanti: \n#{res}"
end

########## CALL TO ACTIONS ##########

def migrate_call_to_actions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, categories_tags_id_map)
  source_call_to_actions = source_db_connection.exec("SELECT * FROM call_to_actions")
  source_call_to_actions_count = source_call_to_actions.count

  puts "call_to_actions: #{source_call_to_actions_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_call_to_actions_count)

  count = 0
  rows_with_cnt_type_missing = 0
  rows_with_cnt_id_missing = 0
  rows_with_category_id_missing = 0
  call_to_actions_id_map = Hash.new

  violetta_tag_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags WHERE name = 'violetta'").values[0][0];
  disney_tag_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags WHERE name = 'disney-channel'").values[0][0];

  if (!violetta_tag_id or !disney_tag_id)
    puts "ERROR: Tag property id not found\n"
  end

  source_call_to_actions.each do |line|
    cnt_type_query_result = source_db_connection.exec("SELECT contents.cnt_type FROM contents JOIN cta_content_interactions ON contents.id = cta_content_interactions.content_id WHERE cta_content_interactions.call_to_action_id = #{line["id"]}").values
    if cnt_type_query_result[0].nil?
      cnt_type = ""
      rows_with_cnt_type_missing += 1
    else
      cnt_type = cnt_type_query_result[0][0]
    end

    content_id = source_db_connection.exec("SELECT content_id FROM cta_content_interactions WHERE call_to_action_id = #{line["id"]}").values[0]
    if content_id.nil?
      rows_with_cnt_id_missing += 1
    else
      if cnt_type == 'Experience::PostContent'
        new_description = source_db_connection.exec("SELECT body FROM post_contents WHERE id = #{content_id[0]}").values
        new_description = new_description[0].nil? ? "" : new_description[0][0]
        media_type = "IMAGE"
        media_data = "NULL"
      else
        new_description = nullify_or_escape_string(source_db_connection, line["long_description"])
        if cnt_type == 'Experience::VideoContent'
          media_type = "FLOWPLAYER"
          video_content_id = source_db_connection.exec("SELECT cnt_id FROM contents WHERE id = #{content_id[0]}").values[0][0]
          media_data = source_db_connection.exec("SELECT vcode FROM video_contents WHERE id = #{video_content_id}").values
          media_data = media_data[0].nil? ? "" : media_data[0][0]
        else
          media_type = "NULL"
          media_data = "NULL"
        end
      end
    end

    updated_at = nullify_or_escape_string(source_db_connection, line["updated_at"])

    fields = {
      #"id" => line["id"].to_i,
      "name" => nullify_or_escape_string(source_db_connection, "#{line["name"]}-id#{line["id"]}".gsub(" ", "")),
      "title" => nullify_or_escape_string(source_db_connection, line["description"]),
      "description" => nullify_or_escape_string(source_db_connection, new_description),
      "media_type" => nullify_or_escape_string(source_db_connection, media_type),
      "enable_disqus" => "f",
      "activated_at" => line["activate_at"] != nil ? nullify_or_escape_string(source_db_connection, line["activate_at"]) : "NULL",
      "secondary_id" => "NULL",
      "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
      "updated_at" => updated_at,
      "slug" => "NULL",
      "media_image_file_name" => nullify_or_escape_string(source_db_connection, line["cta_image_file_name"]),
      "media_image_content_type" => nullify_or_escape_string(source_db_connection, line["cta_image_content_type"]),
      "media_image_file_size" => line["cta_image_file_size"] != nil ? line["cta_image_file_size"] : "NULL",
      "media_image_updated_at" => line["cta_image_updated_at"] != nil ? nullify_or_escape_string(source_db_connection, line["cta_image_updated_at"]) : "NULL",
      "media_data" => nullify_or_escape_string(source_db_connection, media_data),
      "releasing_file_id" => "NULL", # it's not an user cta
      "approved" => line["published_at"] != nil ? "t" : "f",
      "thumbnail_file_name" => "NULL",
      "thumbnail_content_type" => "NULL",
      "thumbnail_file_size" => "NULL",
      "thumbnail_updated_at" => "NULL",
      "user_id" => "NULL", # it's not an user cta
      "aux" => "{}"
    }

    query = build_query_string(destination_db_tenant, "call_to_actions", fields)

    destination_db_connection.exec(query)
    new_cta_id = destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}call_to_actions_id_seq')").values[0][0].to_i
    call_to_actions_id_map.store(line["id"].to_i, new_cta_id)

    if line["cta_category_id"].nil?
      rows_with_category_id_missing += 1
    else
      tag_id = categories_tags_id_map[line["cta_category_id"]]
      create_call_to_action_tag(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, new_cta_id, tag_id, nullify_or_escape_string(source_db_connection, line["updated_at"]))
    end

    # CREATE CALL_TO_ACTION_TAG FOR PROPERTY
    if source_db_tenant == 'violetta'
      create_call_to_action_tag(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, new_cta_id, violetta_tag_id, updated_at)
    end
    create_call_to_action_tag(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, new_cta_id, disney_tag_id, updated_at)

    count += 1
    next_step = print_progress(count + rows_with_cnt_type_missing, lines_step, next_step, source_call_to_actions_count)
  end
  puts "#{count} lines successfully migrated \n"
  puts "#{rows_with_cnt_type_missing} rows had dangling reference to content type \n#{rows_with_cnt_id_missing} rows had dangling reference to content id \n"
  puts "#{rows_with_category_id_missing} rows had no category \n"
  puts ""
  write_table_id_mapping_to_file(source_db_tenant, "call_to_actions", call_to_actions_id_map)
  return call_to_actions_id_map
end

def create_call_to_action_tag(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, new_cta_id, tag_id, created_and_updated_at)
  fields = {
    #"id" => ,
    "call_to_action_id" => new_cta_id,
    "tag_id" => tag_id,
    "created_at" => created_and_updated_at,
    "updated_at" => created_and_updated_at
  }

  query = build_query_string(destination_db_tenant, "call_to_action_tags", fields)

  destination_db_connection.exec(query)
end

########## QUIZZES ##########

def migrate_quizzes(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  source_quizzes = source_db_connection.exec("SELECT * FROM quiz_interactions")
  source_quizzes_count = source_quizzes.count

  puts "quizzes: #{source_quizzes_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_quizzes_count)
  count = 0
  quizzes_id_map = Hash.new

  source_quizzes.each do |line|

    fields = {
      #"id" => line["id"].to_i,
      "question" => nullify_or_escape_string(source_db_connection, line["question"]),
      "cache_correct_answer" => 0,
      "cache_wrong_answer" => 0,
      "quiz_type" => source_db_connection.exec("SELECT name FROM quiz_types where id = #{line["quiz_type_id"]}").values[0][0].upcase,
      "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
      "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
      "one_shot" => "t"
    }

    query = build_query_string(destination_db_tenant, "quizzes", fields)

    destination_db_connection.exec(query)
    quizzes_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}quizzes_id_seq')").values[0][0].to_i)

    count += 1
    next_step = print_progress(count, lines_step, next_step, source_quizzes_count)
  end
  puts "#{count} lines successfully migrated \n"
  write_table_id_mapping_to_file(source_db_tenant, "quizzes", quizzes_id_map)
  return quizzes_id_map
end

########## ANSWERS ##########

def migrate_answers(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, quizzes_id_map)
  source_answers = source_db_connection.exec("SELECT * FROM quiz_answers")
  source_answers_count = source_answers.count

  puts "answers: #{source_answers_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_answers_count)

  count = 0
  answers_id_map = Hash.new

  source_answers.each do |line|

    new_quiz_interaction_id = quizzes_id_map[line["quiz_interaction_id"].to_i]

    fields = {
      #"id" => line["id"],
      "quiz_id" => new_quiz_interaction_id.to_s == '' ? "NULL" : new_quiz_interaction_id,
      "text" => nullify_or_escape_string(source_db_connection, line["answer"]),
      "correct" => line["is_right"] == "t" ? "t" : "f",
      "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
      "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
      "image_file_name" => nullify_or_escape_string(source_db_connection, line["answer_image_file_name"]),
      "image_content_type" => nullify_or_escape_string(source_db_connection, line["answer_image_content_type"]),
      "image_file_size" => line["answer_image_file_size"] != nil ? line["answer_image_file_size"] : "NULL",
      "image_updated_at" => line["answer_image_updated_at"] != nil ? nullify_or_escape_string(source_db_connection, line["answer_image_updated_at"]) : "NULL",
      "call_to_action_id" => "NULL",
      "media_image_file_name" => "NULL",
      "media_image_content_type" => "NULL",
      "media_image_file_size" => "NULL",
      "media_image_updated_at" => "NULL",
      "media_data" => "NULL",
      "media_type" => "NULL",
      "blocking" => "f"
    }

    query = build_query_string(destination_db_tenant, "answers", fields)

    destination_db_connection.exec(query)
    answers_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}answers_id_seq')").values[0][0].to_i)

    count += 1
    next_step = print_progress(count, lines_step, next_step, source_answers_count)
  end
  puts "#{count} lines successfully migrated \n"
  write_table_id_mapping_to_file(source_db_tenant, "answers", answers_id_map)
end

########## CHECKS #########

def migrate_checks(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  source_checks = source_db_connection.exec("SELECT * FROM check_content_interactions")
  source_checks_count = source_checks.count

  puts "checks: #{source_checks_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_checks_count)

  count = 0
  checks_id_map = Hash.new

  source_checks.each do |line|

    fields = {
      #"id" => line["id"].to_i,
      "title" => nullify_or_escape_string(source_db_connection, line["name"]),
      "description" => nullify_or_escape_string(source_db_connection, line["check_text"]),
      "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
      "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"])
    }

    query = build_query_string(destination_db_tenant, "checks", fields)

    destination_db_connection.exec(query)
    checks_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}checks_id_seq')").values[0][0].to_i)

    count += 1
    next_step = print_progress(count, lines_step, next_step, source_checks_count)
  end
  puts "#{count} lines successfully migrated \n"
  write_table_id_mapping_to_file(source_db_tenant, "checks", checks_id_map)
  return checks_id_map
end

########## PLAYS #########

def migrate_plays(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  source_plays = source_db_connection.exec("SELECT * FROM action_video_interactions")
  source_plays_count = source_plays.count

  puts "plays: #{source_plays_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_plays_count)

  count = 0
  plays_id_map = Hash.new

  source_plays.each do |line|

    fields = {
      #"id" => line["id"].to_i,
      "title" => nullify_or_escape_string(source_db_connection, line["name"]),
      "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
      "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"])
    }

    query = build_query_string(destination_db_tenant, "plays", fields)

    destination_db_connection.exec(query)
    plays_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}plays_id_seq')").values[0][0].to_i)

    count += 1
    next_step = print_progress(count, lines_step, next_step, source_plays_count)
  end
  puts "#{count} lines successfully migrated \n"
  write_table_id_mapping_to_file(source_db_tenant, "plays", plays_id_map)
  return plays_id_map
end

########## INTERACTIONS ##########

def migrate_interactions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, call_to_actions_id_map, quizzes_id_map, checks_id_map, plays_id_map)
  source_interactions = source_db_connection.exec("SELECT * FROM interactions")
  source_interactions_count = source_interactions.count

  puts "interactions: #{source_interactions_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_interactions_count)

  count = 0
  interactions_id_map = Hash.new

  source_interactions.each do |line|

    res = source_db_connection.exec("SELECT call_to_action_id FROM cta_content_interactions where interaction_id = #{line["id"]}")
    new_call_to_action_id = res.values != [] ? call_to_actions_id_map[res.values[0][0].to_i] : ""

    fields = {
      #"id" => line["id"].to_i,
      "name" => nullify_or_escape_string(source_db_connection, "#{line["name"]}-id#{line["id"]}".gsub(" ", "")),
      "seconds" => line["video_second"] != nil ? line["video_second"] : 0,
      "when_show_interaction" => (line["intr_type"] != nil and line["intr_type"][12..-12] == ("Versus")) ? "OVERVIDEO_END" : "SEMPRE_VISIBILE",
      "required_to_complete" => (line["intr_type"] != nil and line["intr_type"][12..-12] == ("Quiz" || "Versus" || "CheckContent")) ? "t" : "f",
      "resource_id" => new_resource_id(source_db_connection, destination_db_connection, line["intr_type"], line["intr_id"], quizzes_id_map, checks_id_map, plays_id_map),
      "resource_type" => (line["intr_type"] != nil and line["intr_type"][12..-12] == "ActionVideo") ? "Play" : nullify_or_escape_string(source_db_connection, line["intr_type"][12..-12]),
      "call_to_action_id" => new_call_to_action_id.to_s == "" ? "NULL" : new_call_to_action_id
    }

    query = build_query_string(destination_db_tenant, "interactions", fields)

    destination_db_connection.exec(query)
    interactions_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}interactions_id_seq')").values[0][0].to_i)

    count += 1
    next_step = print_progress(count, lines_step, next_step, source_interactions_count)
  end
  puts "#{count} lines successfully migrated \n"
  write_table_id_mapping_to_file(source_db_tenant, "interactions", interactions_id_map)
  return interactions_id_map
end

def new_resource_id(source_db_connection, destination_db_connection, intr_type, intr_id, quizzes_id_map, checks_id_map, plays_id_map)
  if intr_type == nil
    return "NULL"
  else
    if intr_type[12..-12] == ("Quiz" || "Versus") 
      return quizzes_id_map[intr_id.to_i]
    elsif intr_type[12..-12] == "CheckContent"
      return checks_id_map[intr_id.to_i]
    elsif intr_type[12..-12] == "ActionVideo"
      return plays_id_map[intr_id.to_i]
    else
      return "NULL"
    end
  end
end

########## USERS ##########

def migrate_users(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, limit)
  source_users = source_db_connection.exec("SELECT * FROM users")
  source_users_count = source_users.count

  puts "users: #{source_users_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_users_count)

  count = 0
  count_email_present = 0
  users_id_map = Hash.new
  users_uid_map = Hash.new

  source_users.each do |line|

    email_present_user_id = destination_db_connection.exec("SELECT id, username, avatar_selected_url FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}users WHERE email = '#{nullify_or_escape_string(source_db_connection, line["email"])}'").values.first
    username_present_user_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}users WHERE username = '#{nullify_or_escape_string(source_db_connection, line["nickname"])}'").values.first
    
    if email_present_user_id.nil? # email not present
      if username_present_user_id.nil?
        new_username = nullify_or_escape_string(source_db_connection, line["nickname"])
      else # username present, email not present
        new_username = nullify_or_escape_string(source_db_connection, assign_new_username(destination_db_tenant, destination_db_connection, line["nickname"]))
      end

      email = nullify_or_escape_string(source_db_connection, line["email"])
      if (new_username == "" or new_username == "NULL" or new_username == "scheke")
        new_username = email
        aux = { "profile_completed" => false }.to_json
      else
        aux = { "profile_completed" => true }.to_json
      end

      fields = {
        #"id" => line["id"].to_i,
        "email" => email,
        "encrypted_password" => "NULL",
        "reset_password_token" => "NULL",
        "reset_password_sent_at" => "NULL",
        "remember_created_at" => "NULL",
        "sign_in_count" => line["sign_in_count"],
        "current_sign_in_at" => nullify_or_escape_string(source_db_connection, line["current_sign_in_at"]),
        "last_sign_in_at" => nullify_or_escape_string(source_db_connection, line["last_sign_in_at"]),
        "current_sign_in_ip" => nullify_or_escape_string(source_db_connection, line["current_sign_in_ip"]),
        "last_sign_in_ip" => nullify_or_escape_string(source_db_connection, line["last_sign_in_at"]),
        "first_name" => nullify_or_escape_string(source_db_connection, line["first_name"]),
        "last_name" => nullify_or_escape_string(source_db_connection, line["last_name"]),
        "avatar_selected" => "NULL",
        "swid" => nullify_or_escape_string(source_db_connection, line["swid"]), # Ale dixit
        "privacy" => "t",
        "confirmation_token" => "NULL",
        "confirmed_at" => "NULL",
        "confirmation_sent_at" => "NULL",
        "unconfirmed_email" => "NULL",
        "role" => nullify_or_escape_string(source_db_connection, line["role"]),
        "authentication_token" => "NULL",
        "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
        "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
        "avatar_file_name" => "NULL",
        "avatar_content_type" => "NULL",
        "avatar_file_size" => "NULL",
        "avatar_updated_at" => "NULL",
        "cap" => "NULL",
        "location" => "NULL",
        "province" => "NULL",
        "address" => "NULL",
        "phone" => "NULL",
        "number" => "NULL",
        "rule" => "NULL",
        "birth_date" => "NULL",
        "username" => new_username,
        "newsletter" => "NULL",
        "avatar_selected_url" => nullify_or_escape_string(source_db_connection, line["avatar"]), # alert: in Disney, this is the selected avatar name
        "aux" => aux
      }
  
      query = build_query_string(destination_db_tenant, "users", fields)
  
      destination_db_connection.exec(query)
      new_id = destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}users_id_seq')").values[0][0].to_i
      users_id_map.store(line["id"].to_i, new_id)
      users_uid_map.store(line["uid_encrypted"], new_id)
  
      count += 1
      
    else
      user_id = email_present_user_id[0].to_i
      username = email_present_user_id[1].to_s
      avatar_selected_url = email_present_user_id[2].to_s
      new_avatar_selected_url = nullify_or_escape_string(source_db_connection, line["avatar"]) 
      nickname = nullify_or_escape_string(source_db_connection, line["nickname"])
      count_email_present += 1

      aux = destination_db_connection.exec("SELECT aux FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}users WHERE id = #{user_id}").values[0][0]
      if aux
        aux = JSON.parse(aux)
      else
        aux = { "profile_completed" => true } # for seed users
      end

      if  username_present_user_id.nil? # email present, username not present
        if source_db_tenant == 'disney' # violetta present
          aux = aux.merge({ "violetta_username" => username, "dc_username" => nickname })
          aux = nullify_or_escape_string(source_db_connection, aux.to_json)
          destination_db_connection.exec("UPDATE #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}users SET aux = '#{aux}'::json WHERE id = #{user_id}")
        else # dc present
          aux = aux.merge({ "violetta_username" => nickname, "dc_username" => username })
          aux = nullify_or_escape_string(source_db_connection, aux.to_json)
          destination_db_connection.exec("UPDATE #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}users SET (username, avatar_selected_url, aux) = ('#{nickname}', '#{ new_avatar_selected_url == "NULL" ? avatar_selected_url : new_avatar_selected_url}', '#{aux}'::json) WHERE id = #{user_id}")
        end

      else # username and email present
        aux = aux.merge({ "violetta_username" => nickname, "dc_username" => nickname })
        aux = nullify_or_escape_string(source_db_connection, aux.to_json)
        destination_db_connection.exec("UPDATE #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}users SET aux = '#{aux}'::json WHERE id = #{user_id}")
      end

      users_id_map.store(line["id"].to_i, user_id)
      users_uid_map.store(line["uid_encrypted"], user_id)

    end
    next_step = print_progress(count + count_email_present, lines_step, next_step, source_users_count)
  end
  puts "#{count} lines successfully migrated \n#{count_email_present} users found with same email and successfully updated\n"
  write_table_id_mapping_to_file(source_db_tenant, "users", users_id_map)
  return [users_id_map, users_uid_map]
end

def assign_new_username(destination_db_tenant, destination_db_connection, username_present)
  username_present =~ /.+_[0-9]+$/ ? increase_username_count(destination_db_tenant, destination_db_connection, username_present) : increase_username_count(destination_db_tenant, destination_db_connection, "#{username_present}_1")
end

def increase_username_count(destination_db_tenant, destination_db_connection, username) # username must end with '_[digits]'
  new_username = username
  while destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}users WHERE username = '#{new_username}'").values.first.nil? == false
    i = new_username.length
    while new_username[i] != "_"
      i -= 1
    end
    new_count = new_username[(i + 1)..(new_username.length)].to_i + 1
    return new_username[0..i] + new_count.to_s
  end
end

########## TAGS (CUSTOM GALLERIES) ##########

def migrate_tags(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  source_custom_galleries = source_db_connection.exec("SELECT * FROM core_custom_galleries")
  source_custom_galleries_count = source_custom_galleries.count

  puts "tags (custom_galleries): #{source_custom_galleries_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_custom_galleries_count)

  count = 0
  gallery_tags_id_map = Hash.new

  source_custom_galleries.each do |line|

    fields_for_galleries = {
      #"id" => line["id"].to_i,
      "name" => line["name"],
      "created_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
      "updated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
      "description" => nullify_or_escape_string(source_db_connection, line["description"]),
      "locked" => "f",
      "valid_from" => "NULL",
      "valid_to" => "NULL"
    }

    query_for_galleries = build_query_string(destination_db_tenant, "tags", fields_for_galleries)
    destination_db_connection.exec(query_for_galleries)
    gallery_tags_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags_id_seq')").values[0][0].to_i)

    count += 1
    next_step = print_progress(count, lines_step, next_step, source_custom_galleries_count)
  end

  puts "#{count} lines successfully migrated \n"
  write_table_id_mapping_to_file(source_db_tenant, "gallery_tags", gallery_tags_id_map)
  return gallery_tags_id_map
end

########## USER CALL TO ACTIONS ##########

def migrate_user_call_to_actions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, core_custom_galleries_tags_id)
  source_galleries = source_db_connection.exec("SELECT * FROM core_galleries ORDER BY parent_custom_gallery_id")
  source_galleries_count = source_galleries.count

  puts "user_call_to_actions: #{source_galleries_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_galleries_count)

  count = 0
  rows_with_user_missing = 0
  user_call_to_actions_id_map = Hash.new

  ugc_tag_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags where name = 'ugc'").values[0][0].to_i

  source_galleries.each do |line|

    fields_for_releasing_files = {
      #"id" =>
      "created_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
      "updated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
      "file_file_name" => nullify_or_escape_string(source_db_connection, line["release_file_name"]),
      "file_content_type" => nullify_or_escape_string(source_db_connection, line["release_content_type"]),
      "file_file_size" => line["release_file_size"] != nil ? line["release_file_size"] : "NULL",
      "file_updated_at" => line["release_updated_at"] != nil ? nullify_or_escape_string(source_db_connection, line["release_updated_at"]) : "NULL"
    }
    
    query_for_releasing_files = build_query_string(destination_db_tenant, "releasing_files", fields_for_releasing_files)
    destination_db_connection.exec(query_for_releasing_files)

    new_user_id = users_id_map[line["user_id"].to_i]
    if new_user_id.nil?
      rows_with_user_missing += 1
    else
      description = nullify_or_escape_string(source_db_connection, line["description"])
      updated_at = nullify_or_escape_string(source_db_connection, line["updated_at"])

      fields_for_call_to_actions = {
        #"id" => line["id"].to_i,
        "name" => nullify_or_escape_string(source_db_connection, "id#{line["id"]}".gsub(" ", "")),
        "title" => description.length > 100 ? nullify_or_escape_string(source_db_connection, description[0..100] + "...") : description,
        "description" => description,
        "media_type" => "IMAGE",
        "enable_disqus" => "f",
        "activated_at" => line["published_at"] != nil ? nullify_or_escape_string(source_db_connection, line["published_at"]) : "NULL",
        "secondary_id" => "NULL",
        "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
        "updated_at" => updated_at,
        "slug" => "NULL",
        "media_image_file_name" => nullify_or_escape_string(source_db_connection, line["picture_file_name"]),
        "media_image_content_type" => nullify_or_escape_string(source_db_connection, line["picture_content_type"]),
        "media_image_file_size" => line["cta_image_file_size"] != nil ? line["picture_file_size"] : "NULL",
        "media_image_updated_at" => line["cta_image_updated_at"] != nil ? nullify_or_escape_string(source_db_connection, line["picture_updated_at"]) : "NULL",
        "media_data" => "NULL",
        "releasing_file_id" => destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}releasing_files_id_seq')").values[0][0].to_i,
        "approved" => line["published_at"] != nil ? "t" : "f",
        "thumbnail_file_name" => "NULL",
        "thumbnail_content_type" => "NULL",
        "thumbnail_file_size" => "NULL",
        "thumbnail_updated_at" => "NULL",
        "user_id" => new_user_id, # could it be null?
        "aux" => "{}"
      }
      
      query_for_call_to_actions = build_query_string(destination_db_tenant, "call_to_actions", fields_for_call_to_actions)
  
      destination_db_connection.exec(query_for_call_to_actions)
      user_call_to_actions_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}call_to_actions_id_seq')").values[0][0].to_i)
  
      new_cta_id = destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}call_to_actions_id_seq')").values[0][0].to_i
      if line["parent_custom_gallery_id"] != "NULL"
        create_call_to_action_tag_gallery(source_db_tenant, destination_db_tenant, destination_db_connection, new_cta_id, core_custom_galleries_tags_id[line["parent_custom_gallery_id"]])
      end

      create_call_to_action_tag(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, new_cta_id, ugc_tag_id, updated_at)

      count += 1
      next_step = print_progress(count, lines_step, next_step, source_galleries_count)
    end
  end
  puts "#{count} lines successfully migrated \n#{rows_with_user_missing} rows had dangling reference to user \n"
  write_table_id_mapping_to_file(source_db_tenant, "user_call_to_actions", user_call_to_actions_id_map)
  return user_call_to_actions_id_map
end

def create_call_to_action_tag_gallery(source_db_tenant, destination_db_tenant, destination_db_connection, call_to_action_id, tag_id)

  fields_for_call_to_action_tag = {
    #"id" => ,
    "call_to_action_id" => call_to_action_id,
    "tag_id" => tag_id,
    "created_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
    "updated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
  }

  query_for_call_to_action_tag = build_query_string(destination_db_tenant, "call_to_action_tags", fields_for_call_to_action_tag)
  destination_db_connection.exec(query_for_call_to_action_tag)
end

########## USER INTERACTIONS ##########

def migrate_user_interactions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, interactions_id_map, limit)
  source_user_interactions = source_db_connection.exec("SELECT * FROM cta_ci_users#{limit ? " limit 2000" : ""}") # limit for testing
  source_user_interactions_count = source_user_interactions.count

  puts "user_interactions: #{source_user_interactions_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_user_interactions_count)

  count = 0
  rows_with_interaction_missing = 0
  rows_with_user_missing = 0
  user_interactions_id_map = Hash.new

  source_user_interactions.each do |line|

    old_interaction_id = source_db_connection.exec("SELECT interaction_id FROM cta_content_interactions WHERE id = #{line["cta_content_interaction_id"]}").values.first
    res = source_db_connection.exec("SELECT id FROM cta_ci_user_params WHERE cta_ci_user_id = #{line["id"]}").values.first
    new_user_id = users_id_map[line["user_id"].to_i]

    if old_interaction_id.nil?
      rows_with_interaction_missing += 1
    elsif new_user_id.nil?
      rows_with_user_missing += 1
    else
      new_interaction_id = interactions_id_map[old_interaction_id.first.to_i]

      fields = {
        #"id" => line["id"].to_i,
        "user_id" => new_user_id,
        "interaction_id" => new_interaction_id,
        "answer_id" => res.nil? ? "NULL" : res.first,
        "counter" => 1, # Ale dixit. Alert: check this for Play interactions!
        "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
        "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
        "like" => "NULL", # likes in aux field!
        "outcome" => build_outcome(source_db_connection, line),
        "aux" => "{}"
      }

      query = build_query_string(destination_db_tenant, "user_interactions", fields)
  
      destination_db_connection.exec(query)
      user_interactions_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}user_interactions_id_seq')").values[0][0].to_i)
  
      count += 1
    end

    next_step = print_progress(count + rows_with_user_missing + rows_with_interaction_missing, lines_step, next_step, source_user_interactions_count)
  end
  puts "#{count} lines successfully migrated"
  puts "#{rows_with_interaction_missing} rows had dangling reference to interaction \n#{rows_with_user_missing} rows had dangling reference to user"
  write_table_id_mapping_to_file(source_db_tenant, "user_interactions", user_interactions_id_map)
end

def build_outcome(source_db_connection, line)
  interaction_id = source_db_connection.exec("SELECT interaction_id from cta_content_interactions where id = #{line["cta_content_interaction_id"]}").values[0][0]
  interaction_values = source_db_connection.exec("SELECT intr_type, points FROM interactions WHERE id = #{interaction_id}").values
  interaction_type = interaction_values[0][0][12..-12]
  points = interaction_values[0][1].to_i

  if interaction_type == "CheckContent"
    "{\"win\":{\"attributes\":{\"matching_rules\":[\"CHECK_ANSWER\"],\"reward_name_to_counter\":{\"point\":5},\"unlocks\":[],\"errors\":[],\"info\":[]}},\"correct_answer\":{\"attributes\":{\"matching_rules\":[],\"reward_name_to_counter\":{},\"unlocks\":[],\"errors\":[],\"info\":[]}}}"
  elsif interaction_type == "Versus"
    "{\"win\":{\"attributes\":{\"matching_rules\":[\"VERSUS_ANSWER\"],\"reward_name_to_counter\":{\"point\":5},\"unlocks\":[],\"errors\":[],\"info\":[]}},\"correct_answer\":{\"attributes\":{\"matching_rules\":[],\"reward_name_to_counter\":{},\"unlocks\":[],\"errors\":[],\"info\":[]}}}"
  elsif interaction_type == "ActionVideo" 
    "{\"win\":{\"attributes\":{\"matching_rules\":[\"PLAY_ANSWER\"],\"reward_name_to_counter\":{\"point\":5},\"unlocks\":[],\"errors\":[],\"info\":[]}},\"correct_answer\":{\"attributes\":{\"matching_rules\":[],\"reward_name_to_counter\":{},\"unlocks\":[],\"errors\":[],\"info\":[]}}}"
  elsif interaction_type == "Quiz"
    "{\"win\":{\"attributes\":{\"matching_rules\":[\"TRIVIA_ANSWER\"],\"reward_name_to_counter\":{\"point\":#{points}},\"unlocks\":[],\"errors\":[],\"info\":[]}},\"correct_answer\":{\"attributes\":{\"matching_rules\":[],\"reward_name_to_counter\":{\"point\":10},\"unlocks\":[],\"errors\":[],\"info\":[]},\"unlocks\":[],\"errors\":[],\"info\":[]}}}"
  else
    "{}"
  end
end # Check, like (votes)

########## REWARDS ##########

def migrate_rewards(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  source_rewarding_prizes = source_db_connection.exec("SELECT * FROM rewarding_prizes")
  #source_rewarding_badges = source_db_connection.exec("SELECT * FROM rewarding_badges")
  #source_rewarding_levels = source_db_connection.exec("SELECT * FROM rewarding_levels")
  download_count = 0

  source_rewarding_prizes_count = source_rewarding_prizes.count
  puts "rewards: #{source_rewarding_prizes_count} lines to migrate \nRunning migration..."
  STDOUT.flush

  # POINTS
  #if source_db_tenant == "disney"
  #  generate_point_reward(destination_db_tenant, source_db_connection, destination_db_connection, "point")
  #elsif source_db_tenant == "violetta"
  #  generate_point_reward(destination_db_tenant, source_db_connection, destination_db_connection, "violetta-point")
  #end
  #generate_point_reward(destination_db_tenant, source_db_connection, destination_db_connection, "credit")

  rewards_id_map = Hash.new
  cta_rewards_id_map = Hash.new

  download_count = migrate_source_reward_lines(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, rewards_id_map, cta_rewards_id_map, source_rewarding_prizes, "prize", download_count)
  # ***do not migrate*** migrate_source_reward_lines(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, rewards_id_map, cta_rewards_id_map, source_rewarding_badges, "badge")
  # ***do not migrate*** migrate_source_reward_lines(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, rewards_id_map, cta_rewards_id_map, source_rewarding_levels, "level")

  puts "#{rewards_id_map.length} lines successfully migrated \n"
  write_table_id_mapping_to_file(source_db_tenant, "rewards", rewards_id_map)

  puts "#{cta_rewards_id_map.length} cta_rewards successfully created \n"
  write_table_id_mapping_to_file(source_db_tenant, "cta_rewards", cta_rewards_id_map)

  puts "#{download_count} downloads and download_interactions successfully created \n********************************************************************************* \n\n"

  return rewards_id_map
end

def generate_point_reward(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, reward_name)
  
  reward_with_reward_name = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}rewards WHERE name = '#{reward_name}'").values.first

  if reward_with_reward_name.nil? # create credit only if it doesn't exist yet
    fields = {
      #"id" => ,
      "title" => reward_name,
      "short_description" => "NULL",
      "long_description" => "NULL",
      "button_label" => "NULL",
      "cost" => "NULL",
      "valid_from" => "NULL",
      "valid_to" => "NULL",
      "video_url" => "NULL",
      "media_type" => "DIGITALE",
      "currency_id" => "NULL",
      "spendable" => reward_name == "point" ? "t" : "f",
      "countable" => "t",
      "numeric_display" => "f",
      "name" => reward_name,
      "created_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
      "updated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
      "preview_image_file_name" => "NULL",
      "preview_image_content_type" => "NULL",
      "preview_image_file_size" => "NULL",
      "preview_image_updated_at" => "NULL",
      "main_image_file_name" => "NULL",
      "main_image_content_type" => "NULL",
      "main_image_file_size" => "NULL",
      "main_image_updated_at" => "NULL",
      "media_file_file_name" => "NULL",
      "media_file_content_type" => "NULL",
      "media_file_file_size" => "NULL",
      "media_file_updated_at" => "NULL",
      "not_awarded_image_file_name" => "NULL",
      "not_awarded_image_content_type" => "NULL",
      "not_awarded_image_file_size" => "NULL",
      "not_awarded_image_updated_at" => "NULL",
      "not_winnable_image_file_name" => "NULL",
      "not_winnable_image_content_type" => "NULL",
      "not_winnable_image_file_size" => "NULL",
      "not_winnable_image_updated_at" => "NULL",
      "call_to_action_id" => "NULL"
    }
  
    query = build_query_string(destination_db_tenant, "rewards", fields)
  
    destination_db_connection.exec(query)
    #rewards_id_map.store("#{reward_type}#{line["id"].to_i}", destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}rewards_id_seq')").values[0][0].to_i)
  end

end

def migrate_source_reward_lines(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, rewards_id_map, cta_rewards_id_map, source_rewards, reward_type, download_count)
  source_rewards_count = source_rewards.count
  lines_step, next_step = init_progress(source_rewards_count)
  count = 0
  source_rewards.each do |line|

    #if line["is_video_content"] == "t"
      download_count = create_new_cta_reward(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, line, cta_rewards_id_map, download_count)
    #end

    fields = {
      #"id" => line["id"].to_i,
      "title" => nullify_or_escape_string(source_db_connection, line["title"]),
      "short_description" => nullify_or_escape_string(source_db_connection, line["description"]),
      "long_description" => "NULL",
      "button_label" => "NULL",
      "cost" => line["points"],
      "valid_from" => "NULL",
      "valid_to" => "NULL",
      "video_url" => nullify_or_escape_string(source_db_connection, line["prize_url"]),
      "media_type" => "DIGITALE",
      "currency_id" => "NULL",
      "spendable" => "f",
      "countable" => "f",
      "numeric_display" => "f",
      "name" => nullify_or_escape_string(source_db_connection, line["name"]).gsub('_', '-'),
      "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
      "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
      "preview_image_file_name" => "NULL",
      "preview_image_content_type" => "NULL",
      "preview_image_file_size" => "NULL",
      "preview_image_updated_at" => "NULL",
      "main_image_file_name" => nullify_or_escape_string(source_db_connection, line["prize_image_file_name"]),
      "main_image_content_type" => nullify_or_escape_string(source_db_connection, line["prize_image_file_name"]),
      "main_image_file_size" => line["prize_image_file_size"] != nil ? line["prize_image_file_size"] : "NULL",
      "main_image_updated_at" => line["prize_image_updated_at"] != nil ? nullify_or_escape_string(source_db_connection, line["prize_image_updated_at"]) : "NULL",
      "media_file_file_name" => nullify_or_escape_string(source_db_connection, line["prize_file_file_name"]),
      "media_file_content_type" => nullify_or_escape_string(source_db_connection, line["prize_file_file_name"]),
      "media_file_file_size" => line["prize_file_file_size"] != nil ? line["prize_file_file_size"] : "NULL",
      "media_file_updated_at" => line["prize_file_updated_at"] != nil ? nullify_or_escape_string(source_db_connection, line["prize_file_updated_at"]) : "NULL",
      "not_awarded_image_file_name" => "NULL",
      "not_awarded_image_content_type" => "NULL",
      "not_awarded_image_file_size" => "NULL",
      "not_awarded_image_updated_at" => "NULL",
      "not_winnable_image_file_name" => "NULL",
      "not_winnable_image_content_type" => "NULL",
      "not_winnable_image_file_size" => "NULL",
      "not_winnable_image_updated_at" => "NULL",
      "call_to_action_id" => destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}call_to_actions_id_seq')").values[0][0].to_i
    }

    query = build_query_string(destination_db_tenant, "rewards", fields)

    destination_db_connection.exec(query)
    rewards_id_map.store("#{reward_type}#{line["id"].to_i}", destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}rewards_id_seq')").values[0][0].to_i)
    count += 1
    next_step = print_progress(count, lines_step, next_step, source_rewards_count)
  end
  download_count
end

def create_new_cta_reward(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, line, cta_rewards_id_map, download_count)

  fields = {
    #"id" => line["id"].to_i,
    "name" => nullify_or_escape_string(source_db_connection, "#{line["name"]}-id#{line["id"]}".gsub(" ", "").gsub('_', '-')),
    "title" => nullify_or_escape_string(source_db_connection, line["title"]),
    "description" => nullify_or_escape_string(source_db_connection, line["description"]),
    "media_type" => line["is_video_content"] == "f" ? "IMAGE" : "FLOWPLAYER",
    "enable_disqus" => "f",
    "activated_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
    "secondary_id" => "NULL",
    "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
    "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
    "slug" => "NULL",
    "media_image_file_name" => nullify_or_escape_string(source_db_connection, line["prize_image_file_name"]),
    "media_image_content_type" => nullify_or_escape_string(source_db_connection, line["prize_image_content_type"]),
    "media_image_file_size" => line["cta_image_file_size"] != nil ? line["prize_image_file_size"] : "NULL",
    "media_image_updated_at" => line["cta_image_updated_at"] != nil ? nullify_or_escape_string(source_db_connection, line["prize_image_updated_at"]) : "NULL",
    "media_data" => nullify_or_escape_string(source_db_connection, line["prize_url"]),
    "releasing_file_id" => "NULL",
    "approved" => "t",
    "thumbnail_file_name" => "NULL",
    "thumbnail_content_type" => "NULL",
    "thumbnail_file_size" => "NULL",
    "thumbnail_updated_at" => "NULL",
    "user_id" => "NULL",
    "aux" => "{}"
  }

  query = build_query_string(destination_db_tenant, "call_to_actions", fields)

  destination_db_connection.exec(query)
  new_cta_id = destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}call_to_actions_id_seq')").values[0][0].to_i
  cta_rewards_id_map.store(line["id"].to_i, new_cta_id)

  if line["is_video_content"] == "f"
    create_new_download_and_download_interaction(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, line, new_cta_id)
    download_count += 1
  end

  reward_cta_tag_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}tags WHERE name = 'reward-cta'").values[0][0].to_i
  create_call_to_action_tag(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, new_cta_id, reward_cta_tag_id, nullify_or_escape_string(source_db_connection, line["created_at"]))

  download_count
end

def create_new_download_and_download_interaction(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, line, new_cta_id)

  fields_for_download = {
    #"id" => ,
    "title" => nullify_or_escape_string(source_db_connection, line["name"]),
    "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
    "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
    "attachment_file_name" => nullify_or_escape_string(source_db_connection, line["prize_image_file_name"]),
    "attachment_content_type" => nullify_or_escape_string(source_db_connection, line["prize_image_content_type"]),
    "attachment_file_size" => line["cta_image_file_size"] != nil ? line["prize_image_file_size"] : "NULL",
    "attachment_updated_at" => line["cta_image_updated_at"] != nil ? nullify_or_escape_string(source_db_connection, line["prize_image_updated_at"]) : "NULL"
  }

  query_for_download = build_query_string(destination_db_tenant, "downloads", fields_for_download)

  destination_db_connection.exec(query_for_download)
  download_id = destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}downloads_id_seq')").values[0][0].to_i

  fields_for_download_interaction = {
    #"id" => ,
    "name" => nullify_or_escape_string(source_db_connection, line["name"]),
    "seconds" => 0,
    "when_show_interaction" => "NULL",
    "required_to_complete" => "NULL",
    "resource_id" => download_id,
    "resource_type" => "Download",
    "call_to_action_id" => new_cta_id
  }

  query_for_download_interaction = build_query_string(destination_db_tenant, "interactions", fields_for_download_interaction)

  destination_db_connection.exec(query_for_download_interaction)

end

########## USER_REWARDS ##########

def migrate_user_rewards(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, users_uid_map, rewards_id_map, limit)

  #source_rewarding_badges_users = source_db_connection.exec("SELECT * FROM rewarding_badges_users#{limit ? " limit 500" : ""}") # limit for testing
  #source_rewarding_levels_users = source_db_connection.exec("SELECT * FROM rewarding_levels_users#{limit ? " limit 2000" : ""}") # limit for testing
  source_rewarding_prizes_users = source_db_connection.exec("SELECT * FROM rewarding_prizes_users")

  source_rewarding_prizes_users_count = source_rewarding_prizes_users.count
  puts "user_rewards: #{source_rewarding_prizes_users_count} lines to migrate \nRunning migration..."
  STDOUT.flush

  #badge_counters = migrate_source_rewarding_users_lines(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, rewards_id_map, source_rewarding_badges_users, "badge")
  #level_counters = migrate_source_rewarding_users_lines(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, rewards_id_map, source_rewarding_levels_users, "level")
  prize_counters = migrate_source_rewarding_users_lines(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, users_uid_map, rewards_id_map, source_rewarding_prizes_users, "prize")

  puts "#{prize_counters[0]} lines successfully migrated"
  puts "#{prize_counters[1]} rows had dangling reference to user \n#{prize_counters[2]} rows had dangling reference to reward \n*********************************************************************************\n\n"
  STDOUT.flush
end

def migrate_source_rewarding_users_lines(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, users_uid_map, rewards_id_map, source_rewarding_users, reward_type)
  source_rewarding_users_count = source_rewarding_users.count
  lines_step, next_step = init_progress(source_rewarding_users_count)
  count = 0
  rows_with_user_missing = 0
  rows_with_reward_missing = 0

  source_rewarding_users.each do |line|

    #new_user_id = users_id_map[line["user_id"].to_i]
    rewarding_users_id = line["user_id"]
    lid = source_db_connection.exec("SELECT lid FROM rewarding_users WHERE id = #{rewarding_users_id}").values[0][0]
    new_user_id = users_uid_map[lid]

    if new_user_id.nil?
      puts "ERROR! rewarding_users_id = #{rewarding_users_id}, uid = #{uid}"
    end

    new_reward_id = rewards_id_map["#{reward_type}#{line["prize_id"]}"] # reward_type == "badge" ? rewards_id_map["#{reward_type}#{line["badge_id"]}"] : rewards_id_map["#{reward_type}#{line["level_id"]}"] # caution to type

    if new_user_id.nil?
      rows_with_user_missing += 1
    elsif new_reward_id.nil?
      rows_with_reward_missing += 1
    else
      fields = {
        #"id" => count + 1, # no id...
        "user_id" => new_user_id,
        "reward_id" => new_reward_id,
        "available" => "t",
        "counter" => 0,
        "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
        "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
        "period_id" => "NULL"
      }
  
      query = build_query_string(destination_db_tenant, "user_rewards", fields)
  
      destination_db_connection.exec(query)
      count += 1
      next_step = print_progress(count, lines_step, next_step, source_rewarding_users_count)
    end
  end

  return [count, rows_with_user_missing, rows_with_reward_missing]
end

########## POINTS AND CREDITS (from USER_COUNTERS) ##########

def migrate_user_counters(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_uid_map)
  source_user_counters = source_db_connection.exec("SELECT * FROM rewarding_users")
  source_user_counters_count = source_user_counters.count

  puts "user_rewards_for_points_and_credits: #{source_user_counters_count * 2} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_user_counters_count * 2)
  count = 0
  rows_with_user_missing = 0
  rows_with_updated_credits = 0
  if source_db_tenant == "disney"
    point_reward_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}rewards WHERE name ILIKE 'point'").values[0][0].to_i
  elsif source_db_tenant == "violetta"
    point_reward_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}rewards WHERE name ILIKE 'violetta-point'").values[0][0].to_i
  end
  credit_reward_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}rewards WHERE name ILIKE 'credit'").values[0][0].to_i

  source_user_counters.each do |line|
    new_user_id = users_uid_map[line["lid"]]
    if new_user_id.nil?
      rows_with_user_missing += 1
    else
      fields_for_points = {
        #"id" => line["id"].to_i,
        "user_id" => new_user_id,
        "reward_id" => point_reward_id,
        "available" => "t",
        "counter" => line["given_points"],
        "created_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
        "updated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
        "period_id" => "NULL"
      }

      query_for_points = build_query_string(destination_db_tenant, "user_rewards", fields_for_points)
      destination_db_connection.exec(query_for_points)
      count += 1

      credits_present_for_user_user_reward_id = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}user_rewards WHERE user_id = #{new_user_id.to_i} AND reward_id = #{credit_reward_id}").values.first

      if credits_present_for_user_user_reward_id.nil? # no credits for user
        fields_for_credits = {
          #"id" => line["id"].to_i,
          "user_id" => new_user_id,
          "reward_id" => credit_reward_id,
          "available" => "t",
          "counter" => line["points"],
          "created_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
          "updated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
          "period_id" => "NULL"
        }
    
        query_for_credits = build_query_string(destination_db_tenant, "user_rewards", fields_for_credits)
    
        destination_db_connection.exec(query_for_credits)

        #user_rewards_id_map.store...
        count += 1

      else # add credits to user
        destination_db_connection.exec("UPDATE #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}user_rewards SET counter = counter + #{line["points"]} WHERE user_id = #{new_user_id.to_i} AND reward_id = #{credit_reward_id}")
        rows_with_updated_credits += 1
      end
    end
    next_step = print_progress(count + rows_with_user_missing + rows_with_updated_credits, lines_step, next_step, source_user_counters_count)
  end
  puts "#{count} lines successfully created"
  puts "#{rows_with_user_missing} rows had dangling reference to user \n#{rows_with_updated_credits} rows updated for credits \n********************************************************************************* \n"
  STDOUT.flush
  #write_table_id_mapping_to_file(source_db_tenant, "user_rewards", user_rewards_id_map)
end

########## COMMENTS + USER_COMMENT_INTERACTIONS [+ NEW INTERACTIONS] ##########

def migrate_comments_and_user_comment_interactions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, call_to_actions_id_map, users_id_map, limit)
  source_comments_and_user_comment_interactions = source_db_connection.exec("SELECT * FROM comments ORDER BY content_id#{limit ? " limit 20000" : ""}") # limit for testing
  source_comments_and_user_comment_interactions_count = source_comments_and_user_comment_interactions.count

  puts "comments & user_comment_interactions: #{source_comments_and_user_comment_interactions_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_comments_and_user_comment_interactions_count)
  count_for_user_comment_interactions = 0
  count_for_comments = 0
  rows_with_user_missing = 0
  user_comment_interactions_id_map = Hash.new

  last_content_id = 0
  last_comment_id = 0

  source_comments_and_user_comment_interactions.each do |line|
    
    if line["content_id"] != last_content_id # create new comment and interaction entries

      last_content_id = line["content_id"]
      
      res = source_db_connection.exec("SELECT created_at FROM contents WHERE id = #{line["content_id"]}").values.first

      fields_for_comments = {
        #"id" => count_for_comments + 1,
        "must_be_approved" => "t",
        "title" => "#COMMENT#{res.nil? ? "" : res.first}",
        "created_at" => res.nil? ? "NULL" : res.first,
        "updated_at" => res.nil? ? "NULL" : res.first
      }

      query_for_comments = build_query_string(destination_db_tenant, "comments", fields_for_comments)
      destination_db_connection.exec(query_for_comments)
      last_comment_id = destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}comments_id_seq')").values[0][0].to_i

      ### COMMENTS REFERENCE CTA CREATING A NEW INTERACTION ###

      new_call_to_action_id = call_to_actions_id_map[source_db_connection.exec("SELECT call_to_action_id FROM cta_content_interactions WHERE content_id = #{line["content_id"]}").values[0][0].to_i]

      fields_for_interactions = {
        #"id" => last_interaction_id + 1,
        "name" => "NULL", # always NULL for comments
        "seconds" => 0,
        "when_show_interaction" => "SEMPRE_VISIBILE",
        "required_to_complete" => "f",
        "resource_id" => last_comment_id,
        "resource_type" => "Comment",
        "call_to_action_id" => new_call_to_action_id # Disney -> reference to content, Fandom -> reference to cta
      }

      query_for_interactions = build_query_string(destination_db_tenant, "interactions", fields_for_interactions)

      destination_db_connection.exec(query_for_interactions)
      count_for_comments += 1
      #last_interaction_id += 1

    end

    new_user_id = users_id_map[line["user_id"].to_i]

    if new_user_id.nil?
      rows_with_user_missing += 1
    else
      fields_for_user_comment_interactions = {
        #"id" => line["id"].to_i,
        "user_id" => new_user_id, # users may be missing
        "comment_id" => last_comment_id, # assign according to content_id
        "text" => nullify_or_escape_string(source_db_connection, line["body"]),
        "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
        "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
        "approved" => line["published_at"].nil? ? "f" : "t"
      }

      query_for_user_comment_interactions = build_query_string(destination_db_tenant, "user_comment_interactions", fields_for_user_comment_interactions)
  
      destination_db_connection.exec(query_for_user_comment_interactions)
      user_comment_interactions_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}user_comment_interactions_id_seq')").values[0][0].to_i)
  
      count_for_user_comment_interactions += 1
    end
    next_step = print_progress(count_for_user_comment_interactions + rows_with_user_missing, lines_step, next_step, source_comments_and_user_comment_interactions_count)

  end
  puts "#{count_for_comments} lines successfully generated for comments and interactions\n"
  puts "#{count_for_user_comment_interactions} lines successfully migrated for user_comment_interactions \n#{rows_with_user_missing} rows had dangling reference to user"
  write_table_id_mapping_to_file(source_db_tenant, "user_comment_interactions", user_comment_interactions_id_map)
  return user_comment_interactions_id_map
end

#def get_next_comment_id(destination_db_connection, last_comment_id)
#  puts destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}comments_id_seq')")
#  currval = destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}comments_id_seq')").values[0][0].to_i
#  currval.nil? ? 1 : currval + 1
#end

########## VOTES ##########

def migrate_votes(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, call_to_actions_id_map, user_call_to_actions_id_map, limit)
  source_votes = source_db_connection.exec("SELECT * FROM votes ORDER BY votable_type, votable_id#{limit ? " limit 20000" : ""}") # limit for testing
  source_votes_count = source_votes.count

  puts "votes: #{source_votes_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_votes_count)
  like_interaction_count = 0
  count = 0
  rows_with_user_missing = 0
  rows_with_cta_missing = 0
  last_interaction_type_and_id = [nil, nil]
  votes_id_map = Hash.new

  source_votes.each do |line|
    new_user_id = users_id_map[line["voter_id"].to_i]
    new_call_to_action_id = nil
    if new_user_id.nil?
      rows_with_user_missing += 1
    elsif line["votable_type"] == "Core::Gallery" # user_cta
      user_call_to_actions_id_map[line["votable_id"].to_i].nil? ? rows_with_cta_missing += 1 : new_call_to_action_id = user_call_to_actions_id_map[line["votable_id"].to_i]
    else # cta
      res = source_db_connection.exec("SELECT call_to_action_id FROM cta_content_interactions WHERE content_id = #{line["votable_id"]}")
      res.values == [] ? rows_with_cta_missing += 1 : new_call_to_action_id = call_to_actions_id_map[res.values[0][0].to_i]
    end

    if new_call_to_action_id != nil

      if last_interaction_type_and_id != [line["votable_type"], line["votable_id"]]

        last_interaction_type_and_id = [line["votable_type"], line["votable_id"]]

        fields_for_likes = {
          #"id" => , 
          "title" => "like-id#{line["id"]}",
          "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
          "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"])
        }

        query_for_likes = build_query_string(destination_db_tenant, "likes", fields_for_likes)
        destination_db_connection.exec(query_for_likes)

        fields_for_interactions = {
          #"id" => line["id"].to_i,
          "name" => nullify_or_escape_string(source_db_connection, "interaction-like-#{source_db_tenant}-id#{line["id"]}"),
          "seconds" => 0,
          "when_show_interaction" => "SEMPRE_VISIBILE",
          "required_to_complete" => "f",
          "resource_id" => destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}likes_id_seq')").values[0][0].to_i, # created above
          "resource_type" => "Like",
          "call_to_action_id" => new_call_to_action_id
        }

        query_for_interactions = build_query_string(destination_db_tenant, "interactions", fields_for_interactions)
        destination_db_connection.exec(query_for_interactions)
        like_interaction_count += 1
      end

      if new_user_id != nil # don't create user_interaction if there is no user mapped
        fields_for_user_interactions = {
          #"id" => line["id"].to_i,
          "user_id" => new_user_id,
          "interaction_id" => destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}interactions_id_seq')").values[0][0].to_i, # created above
          "answer_id" => "NULL",
          "counter" => 1,
          "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
          "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
          "like" => "NULL", # likes in aux field!
          "outcome" => "NULL",
          "aux" => '{"like":true}'
        }
    
        query_for_user_interactions = build_query_string(destination_db_tenant, "user_interactions", fields_for_user_interactions)
        destination_db_connection.exec(query_for_user_interactions)

        votes_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}interactions_id_seq')").values[0][0].to_i)
    
        count += 1
      end
    end
    next_step = print_progress(count + rows_with_user_missing + rows_with_cta_missing, lines_step, next_step, source_votes_count)
  end
  puts "#{like_interaction_count} lines successfully generated for likes and interactions \n#{count} lines successfully migrated for like user_interactions \n"
  puts "#{rows_with_user_missing} rows had dangling reference to user \n#{rows_with_cta_missing} rows had dangling reference to cta"
  write_table_id_mapping_to_file(source_db_tenant, "votes", votes_id_map)
end

def migrate_notices(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map, user_comment_interactions_id_map)
  source_notices = source_db_connection.exec("SELECT * FROM rewarding_notifications")
  source_notices_count = source_notices.count

  puts "notices: #{source_notices_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step, next_step = init_progress(source_notices_count)
  count = 0
  rows_with_user_missing = 0
  rows_with_user_comment_interaction_missing = 0

  notices_id_map = Hash.new

  source_notices.each do |line|

    new_user_id = users_id_map[line["user_id"].to_i]
    new_user_comment_interaction_id = int?(line["url"]) ? user_comment_interactions_id_map[line["url"].to_i] : nil

    if new_user_id.nil?
      rows_with_user_missing += 1
    elsif (line["notification_type"] == 'comment' || line["notification_type"] == 'comment-pic' || line["notification_type"] == 'pic-published') and new_user_comment_interaction_id.nil?
      rows_with_user_comment_interaction_missing += 1
    else
      fields_for_notices = {
        #"id" => line["id"].to_i,
        "user_id" => new_user_id,
        "html_notice" => nullify_or_escape_string(source_db_connection, line["message"]),
        "last_sent" => nullify_or_escape_string(source_db_connection, line["created_at"]),
        "viewed" => "t",
        "read" => line["read_at"].nil? ? "f" : "t",
        "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
        "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
        "aux" => build_notice_aux(source_db_connection, line["notification_type"], new_user_comment_interaction_id, line["message"])
      }
  
      query_for_notices = build_query_string(destination_db_tenant, "notices", fields_for_notices)
      destination_db_connection.exec(query_for_notices)
      notices_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}notices_id_seq')").values[0][0].to_i)
  
      count += 1
    end
    next_step = print_progress(count + rows_with_user_missing + rows_with_user_comment_interaction_missing, lines_step, next_step, source_notices_count)
  end

  puts "#{count} lines successfully migrated \n"
  puts "#{rows_with_user_missing} rows had dangling reference to user \n#{rows_with_user_comment_interaction_missing} rows had dangling reference to user_comment_interaction"
  write_table_id_mapping_to_file(source_db_tenant, "notices", notices_id_map)
  return notices_id_map
end

def build_notice_aux(source_db_connection, notification_type, new_user_comment_interaction_id, message)
  if new_user_comment_interaction_id.nil?
    aux = { "original_message" => nullify_or_escape_string(source_db_connection, message) }
  else
    aux = { "original_message" => nullify_or_escape_string(source_db_connection, message), "comment_id" => new_user_comment_interaction_id }
  end
  nullify_or_escape_string(source_db_connection, aux.to_json)
  #"{\"original_message\":\"#{nullify_or_escape_string(source_db_connection, line["message"])}#{(notification_type == 'comment' and url != 'url') ? "\",\"comment_id\":\"" + nullify_or_escape_string(source_db_connection, message) : ""}\"}"
end

def create_comment_and_like_interaction_for_cta_with_no_comments_or_likes(destination_db_connection, destination_db_tenant)
  call_to_actions_ids = destination_db_connection.exec("SELECT id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}call_to_actions")
  call_to_actions_count = call_to_actions_ids.count

  call_to_actions_ids_array = Array.new
  call_to_actions_ids.each do |id|
    call_to_actions_ids_array << id["id"].to_i
  end

  ### COMMENTS ###

  call_to_actions_with_comments_ids = destination_db_connection.exec("SELECT call_to_action_id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}interactions WHERE resource_type = 'Comment'")

  call_to_actions_with_comments_ids_array = Array.new
  call_to_actions_with_comments_ids.each do |id|
    call_to_actions_with_comments_ids_array << id["call_to_action_id"].to_i
  end

  call_to_actions_without_comments_ids_array = call_to_actions_ids_array - call_to_actions_with_comments_ids_array

  puts "#{call_to_actions_without_comments_ids_array.size} call to actions without comment interaction on #{call_to_actions_count} call to actions \n"
  puts "Creating comment interactions... \n"

  count_for_comments = 0

  call_to_actions_without_comments_ids_array.each do |id|
    fields_for_comments = {
      #"id" => count_for_comments + 1,
      "must_be_approved" => "t",
      "title" => "#COMMENTCTA#{id}",
      "created_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
      "updated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    }

    query_for_comments = build_query_string(destination_db_tenant, "comments", fields_for_comments)
    destination_db_connection.exec(query_for_comments)
    last_comment_id = destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}comments_id_seq')").values[0][0].to_i

    ### COMMENTS REFERENCE CTA CREATING A NEW INTERACTION ###

    fields_for_interactions = {
      #"id" => last_interaction_id + 1,
      "name" => "NULL", # always NULL for comments
      "seconds" => 0,
      "when_show_interaction" => "SEMPRE_VISIBILE",
      "required_to_complete" => "t",
      "resource_id" => last_comment_id,
      "resource_type" => "Comment",
      "call_to_action_id" => id
    }

    query_for_interactions = build_query_string(destination_db_tenant, "interactions", fields_for_interactions)

    destination_db_connection.exec(query_for_interactions)
    count_for_comments += 1
  end

  puts "#{count_for_comments} comments and comment interactions successfully created\n\n"

  ### LIKES ###

  call_to_actions_with_likes_ids = destination_db_connection.exec("SELECT call_to_action_id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}interactions WHERE resource_type = 'Like'")

  call_to_actions_with_likes_ids_array = Array.new
  call_to_actions_with_likes_ids.each do |id|
    call_to_actions_with_likes_ids_array << id["call_to_action_id"].to_i
  end

  call_to_actions_without_likes_ids_array = call_to_actions_ids_array - call_to_actions_with_likes_ids_array

  puts "#{call_to_actions_without_likes_ids_array.size} call to actions without like interaction on #{call_to_actions_count} call to actions \n"
  puts "Creating like interactions... \n"

  count_for_likes = 0

  call_to_actions_without_likes_ids_array.each do |id|
    fields_for_likes = {
      #"id" => , 
      "title" => "like-cta#{id}",
      "created_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
      "updated_at" => Time.now.utc.strftime("%Y-%m-%d %H:%M:%S")
    }

    query_for_likes = build_query_string(destination_db_tenant, "likes", fields_for_likes)
    destination_db_connection.exec(query_for_likes)

    fields_for_interactions = {
      #"id" => line["id"].to_i,
      "name" => "interaction-like-cta-id#{id}",
      "seconds" => 0,
      "when_show_interaction" => "SEMPRE_VISIBILE",
      "required_to_complete" => "f",
      "resource_id" => destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}likes_id_seq')").values[0][0].to_i, # created above
      "resource_type" => "Like",
      "call_to_action_id" => id
    }

    query_for_interactions = build_query_string(destination_db_tenant, "interactions", fields_for_interactions)
    destination_db_connection.exec(query_for_interactions)
    count_for_likes += 1
  end

  puts "#{count_for_likes} likes and like interactions successfully created\n\n"

end

def nullify_or_escape_string(conn, str)
  if str.nil?
    "NULL"
  else
    conn.escape_string(str)
  end
end

def build_query_string(destination_db_tenant, table, hash)
  keys = hash.keys.map { |x| x.to_s }.join(', ') 
  values = hash.values.map { |x| "'#{x}'" }.join(', ')
  #add_default_value_for_id!(keys, values) unless hash.has_key?("id") 

  "INSERT INTO #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}#{table} (#{keys}) VALUES (#{values})".gsub("'NULL'", "NULL").gsub("like, ", "\"like\", ") # last gsub is really awful... delete it as
end

=begin
def add_default_value_for_id!(keys, values)
  keys.insert(0, "id, ")
  values.insert(0, "DEFAULT, ")
  puts "keys: #{keys}"
  puts "values: #{values}"
end
=end

def write_table_id_mapping_to_file(source_db_tenant, table, hash)

  tables_id_mapping_file_name = "files/" + source_db_tenant + "_tables_id_mapping.txt"
  File.open(tables_id_mapping_file_name, "a") { |file| 
    file.print("#{table}: #{hash}\n\n")
  }

  puts "IDs' mapping written to #{tables_id_mapping_file_name} \n*********************************************************************************\n\n"
  STDOUT.flush
end

def write_and_store_time(source_db_tenant, interval_name)
  FileUtils.mkdir_p "files" # mkdir if not existing
  time = Time.now
  time_log_file_name = "files/time_log_" + time.strftime("%Y-%m-%d").to_s + ".txt"
  
  File.open(time_log_file_name, "a") { |file| 
    file.print("#{interval_name} #{source_db_tenant} migration at: #{time}\n\n")
  }
  puts "#{interval_name} #{source_db_tenant} migration at: #{time} \n*********************************************************************************\n\n"
  STDOUT.flush
end

def int?(str) # method to define if a string represents an integer
  unless str.nil?
    !!(str =~ /\A[-+]?[0-9]+\z/)
  else
    false
  end
end

def init_progress(count)
  if count > BIG_NUMBER_OF_LINES
    val = (count * 0.1).floor
    return val, val
  else
    return 0, 0
  end
end

def print_progress(count, lines_step, next_step, total_count)
  if count == next_step
    puts "#{count} lines processed \n"
    STDOUT.flush
    next_step + lines_step
  else
    next_step
  end
end

def migrate_db(source_db_connection, source_db_tenant, destination_db_connection, destination_db_tenant, limit)
  write_and_store_time(source_db_tenant, "start")

  FileUtils.mkdir_p "files" # mkdir if not existing
  tables_id_mapping_file_name = "files/" + source_db_tenant + "_tables_id_mapping.txt"
  id_mapping_file = File.open(tables_id_mapping_file_name, "w") { |file| 
    file.truncate(0)
  }

  categories_tags_id_map = map_category_ids_to_tag_ids(source_db_connection, source_db_tenant, destination_db_connection, destination_db_tenant)
  core_custom_galleries_tags_id = map_core_custom_gallery_ids_to_tag_ids(source_db_connection, source_db_tenant, destination_db_connection, destination_db_tenant)

  call_to_actions_id_map = migrate_call_to_actions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, categories_tags_id_map)
  quizzes_id_map = migrate_quizzes(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  migrate_answers(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, quizzes_id_map)
  checks_id_map = migrate_checks(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  plays_id_map = migrate_plays(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  interactions_id_map = migrate_interactions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, call_to_actions_id_map, quizzes_id_map, checks_id_map, plays_id_map)
  users_id_map = migrate_users(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, limit)
  # *** DO NOT MIGRATE *** gallery_tags_id_map_old = migrate_tags(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  user_call_to_actions_id_map = migrate_user_call_to_actions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map[0], core_custom_galleries_tags_id)
  migrate_user_interactions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map[0], interactions_id_map, limit)
  rewards_id_map = migrate_rewards(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection)
  migrate_user_rewards(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map[0], users_id_map[1], rewards_id_map, limit)
  migrate_user_counters(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map[1])
  user_comment_interactions_id_map = migrate_comments_and_user_comment_interactions(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, call_to_actions_id_map, users_id_map[0], limit)
  migrate_votes(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map[0], call_to_actions_id_map, user_call_to_actions_id_map, limit)
  # *** DO NOT MIGRATE *** migrate_notices(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, users_id_map[0], user_comment_interactions_id_map)

  destination_db_connection.exec("UPDATE #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}interactions SET resource_type = 'Check' WHERE resource_type = 'CheckContent'");

  write_and_store_time(source_db_tenant, "end")
end

def main()

  if ARGV.size < 1
    puts <<-EOF
    Usage: #{$0} <configuration_file_path>
    Runs disney and violetta databases migration into a new fandom schema structured database using 
    options defined in <configuration_file_path> YAML file.
    EOF
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)

  source_db_tenants = [config["source_db_tenants"][0], config["source_db_tenants"][1]]
  destination_db_tenant = (config["destination_db_tenant"].nil? or config["destination_db_tenant"] == "null") ? nil : config["destination_db_tenant"]
  source_db_connections = [PG::Connection.open(:dbname => config["source_db_names"][0]), PG::Connection.open(:dbname => config["source_db_names"][1])]
  destination_db_connection = PG::Connection.open(:dbname => config["destination_db_name"])
  limit = config["limit_lines"]

  migrate_db(source_db_connections[0], source_db_tenants[0], destination_db_connection, destination_db_tenant, limit)
  migrate_db(source_db_connections[1], source_db_tenants[1], destination_db_connection, destination_db_tenant, limit)

  create_comment_and_like_interaction_for_cta_with_no_comments_or_likes(destination_db_connection, destination_db_tenant)
end

main()