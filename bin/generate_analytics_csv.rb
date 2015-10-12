require "pg"
require "yaml"
require "logger"
require "csv"
require "fileutils"

def main

  if ARGV.size != 1
    puts <<-EOF
      Usage: #{$0} <config.yml>
    EOF
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)

  rails_app_dir = config["rails_app_dir"]
  tenant = config["tenant"]
  starting_date = config["starting_date"]
  ending_date = config["ending_date"]
  main_tag_name = config["main_tag_name"]
  other_tags_names = config["other_tags_names"].gsub(" ", "").split(",")

  csv_path = "#{rails_app_dir}/bin/files"

  logger = Logger.new("#{rails_app_dir}/log/generate_analytics_csv.log")

  FileUtils::mkdir_p(csv_path)

  starting_date.each_with_index do |sd, i|

    start_time = Time.now
    ed = ending_date[i]
    csv_file_name = "#{main_tag_name}_#{sd}_#{ed}.csv"

    CSV.open("#{csv_path}/#{csv_file_name}", "wb") do |csv|

      logger.info("starting analytics csv generation from #{sd} to #{ed} for main tag \"#{main_tag_name}\" and other tags #{other_tags_names.join(", ")}")

      conn = PG::Connection.open(config["db"])
      if tenant
        conn.exec("SET search_path = '#{tenant}'")
      end

      interaction_types = conn.exec("SELECT DISTINCT resource_type FROM interactions;").field_values("resource_type").sort! # Array
      logger.info("interaction types retrieved: #{interaction_types.join(", ")}")
      csv << [" "] + interaction_types

      main_tag = get_tag_with_name(conn, logger, main_tag_name)
      if main_tag.nil?
        exit
      end

      cta_with_main_tag_ids = get_cta_ids_with_tag(conn, logger, main_tag["id"])

      other_tags_names.each do |other_tags_name|
        other_tag = get_tag_with_name(conn, logger, other_tags_name)
        if other_tag
          values_hash = get_user_interactions_values(conn, logger, cta_with_main_tag_ids, [other_tag], interaction_types, sd, ed)
          values_array = values_hash.values
          csv << [other_tags_name] + values_array
        end
      end

    end
    
    logger.info("#{main_tag_name} csv file generated in #{Time.now - start_time} seconds")

  end

end

def get_user_interactions_values(conn, logger, cta_with_main_tag_ids, tags, interaction_types, starting_date, ending_date)
  user_interaction_values = {}
  call_to_action_with_other_tags_ids = nil

  tags.each_with_index do |tag, i|
    if i > 0
      call_to_action_with_other_tags_ids = call_to_action_with_other_tags_ids && get_cta_ids_with_tag(conn, logger, tag["id"])
    else
      call_to_action_with_other_tags_ids = get_cta_ids_with_tag(conn, logger, tag["id"])
    end
  end

  logger.info("getting id - resource_type map for interactions belonging to call to actions having \"#{tags.map{|tag| tag["name"]}.join("\",\"")}\" tag(s) and main tag")

  id_interaction_type_array = conn.exec(
    "SELECT id, resource_type 
    FROM interactions 
    WHERE call_to_action_id IN (
      #{(cta_with_main_tag_ids && call_to_action_with_other_tags_ids).join(",")}
    )"
  ).to_a

  logger.info("getting counter values for every resource_type")

  interaction_types.each do |interaction_type|

    logger.info("#{interaction_type}...")

    interaction_ids = []
    id_interaction_type_array.select{ |h| h["resource_type"] == interaction_type }.each do |hash|
      interaction_ids << hash["id"].to_i
    end

    if interaction_ids.any?
      counter = conn.exec(
        "SELECT SUM(counter) AS count 
        FROM user_interactions 
        WHERE created_at BETWEEN '#{starting_date} 00:00:00' AND '#{ending_date} 23:59:59' 
        AND interaction_id IN (#{interaction_ids.join(",")})"
      ).first["count"]
    else
      counter = 0
    end

    user_interaction_values[interaction_type] = counter.to_i

  end

  user_interaction_values
end

def get_cta_ids_with_tag(conn, logger, tag_id)
  logger.info("getting call to actions with tag #{tag_id}...")
  conn.exec("SELECT call_to_action_id FROM call_to_action_tags WHERE tag_id = #{tag_id}").field_values("call_to_action_id").map{|id| id.to_i}
end

def get_tag_with_name(conn, logger, tag_name)
  logger.info("getting tag with name \"#{tag_name}\"...")
  tag = conn.exec("SELECT * FROM tags WHERE name = '#{tag_name}'").first
  if tag.nil?
    logger.error("cannot find tag with name \"#{tag_name}\"")
    nil
  end
  tag
end

main()