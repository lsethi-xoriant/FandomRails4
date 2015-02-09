require "yaml"
require "pg"
require "json"
require "fileutils"
require "ruby-debug"

def migrate_comment_galleries(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, call_to_actions_id_map, users_id_map)
  source_comments = source_db_connection.exec("SELECT * FROM core_comment_galleries ORDER BY gallery_id")
  source_comments_count = source_comments.count

  puts "comment galleries: #{source_comments_count} lines to migrate \nRunning migration..."
  STDOUT.flush
  lines_step = init_progress(source_comments_count)
  next_step = lines_step
  count_for_user_comment_interactions = 0
  count_for_comments = 0
  rows_with_user_missing = 0
  rows_with_gallery_missing = 0
  user_comment_interactions_id_map = Hash.new

  last_gallery_id = 0
  call_to_action_id = 0

  ddl_file_name = "files/" + source_db_tenant + "_ddl.txt"
  id_mapping_file = File.open(ddl_file_name, "w") { |ddl| 
    ddl.truncate(0)

    source_comments.each do |line|
      
      if line["gallery_id"] != last_gallery_id # update last_gallery_id and comment_id
        last_gallery_id = line["gallery_id"]
        call_to_action_id = call_to_actions_id_map[last_gallery_id].to_i
      end

      if call_to_action_id == 0
          rows_with_gallery_missing += 1
      else
        comment_id = destination_db_connection.exec("SELECT resource_id FROM #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}interactions WHERE resource_type = 'Comment' AND call_to_action_id = #{call_to_action_id}").values[0][0].to_i
        new_user_id = users_id_map[line["user_id"]]

        if new_user_id.nil?
          rows_with_user_missing += 1
        else
          fields_for_user_comment_interactions = {
            #"id" => line["id"].to_i,
            "user_id" => new_user_id, # users may be missing
            "comment_id" => comment_id, # assign according to gallery_id
            "text" => nullify_or_escape_string(source_db_connection, line["body"]),
            "created_at" => nullify_or_escape_string(source_db_connection, line["created_at"]),
            "updated_at" => nullify_or_escape_string(source_db_connection, line["updated_at"]),
            "approved" => (line["published_at"].nil? or line["published_at"] == 'f') ? "f" : "t"
          }

          query_for_user_comment_interactions = build_query_string(destination_db_tenant, "user_comment_interactions", fields_for_user_comment_interactions)

          #destination_db_connection.exec(query_for_user_comment_interactions)
          #user_comment_interactions_id_map.store(line["id"].to_i, destination_db_connection.exec("SELECT currval('#{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}user_comment_interactions_id_seq')").values[0][0].to_i)
          ddl.write(query_for_user_comment_interactions + ";\n")

          count_for_user_comment_interactions += 1
        end
      end
        next_step = print_progress(count_for_user_comment_interactions + rows_with_user_missing + rows_with_gallery_missing, lines_step, next_step, source_comments_count)
    end
  }

  puts "#{count_for_user_comment_interactions} lines successfully migrated for user_comment_interactions \n#{rows_with_user_missing} rows had dangling reference to user \n#{rows_with_gallery_missing} rows had dangling reference to call_to_action \n"
  write_table_id_mapping_to_file(source_db_tenant, "user_comment_interactions_from_galleries", user_comment_interactions_id_map)
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

  "INSERT INTO #{destination_db_tenant.nil? ? "" : destination_db_tenant + "."}#{table} (#{keys}) VALUES (#{values})".gsub("'NULL'", "NULL").gsub("like, ", "\"like\", ") # last gsub is really awful... delete it as
end

def write_table_id_mapping_to_file(source_db_tenant, table, hash)

  tables_id_mapping_file_name = "files/" + source_db_tenant + "_comment_galleries_tables_id_mapping.txt"
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
  (count * 0.1).floor
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

def create_id_hashes(id_file)
  file = File.open(id_file, "rb")
  maps = file.read # string
  [table_hash("user_call_to_actions", maps), table_hash("users", maps)]
  
end

def table_hash(name, maps)

  string = maps.slice((maps.index("#{name}:"))..-1)
  if name == "users"
    string = string.slice(string.index('{'), string.index('}'))[1 .. -8]
  elsif name == "user_call_to_actions"
    string = string.slice(string.index('{'), string.index('}'))[1 .. -23]
  end
  s = string.split(',').map { |pair| pair.strip.split('=>').map { |x| "\"#{x.to_i}\"" }.join(':') }.join(',')
  puts "#{name} string to parse: #{s[0..30]} ..... #{s[-30..-1]}"
  hash = JSON.parse("{" + s + "}")
  return hash

end

def migrate_db(source_db_connection, source_db_tenant, destination_db_connection, destination_db_tenant, call_to_actions_id_map, users_id_map)
  write_and_store_time(source_db_tenant, "start")

  FileUtils.mkdir_p "files" # mkdir if not existing
  tables_id_mapping_file_name = "files/" + source_db_tenant + "_comment_galleries_tables_id_mapping.txt"
  id_mapping_file = File.open(tables_id_mapping_file_name, "w") { |file| 
    file.truncate(0)
  }

  migrate_comment_galleries(source_db_tenant, destination_db_tenant, source_db_connection, destination_db_connection, call_to_actions_id_map, users_id_map)

  write_and_store_time(source_db_tenant, "end")
end

def main()

  if ARGV.size != 1
    puts <<-EOF
    Usage: #{$0} <configuration_file_path>
    Migrate comment_gallery table from violetta and disneychannel database 
    creating user_comment_interactions' entries to destination disney database 
    using options defined in <configuration_file_path> YAML file.
    EOF
    exit
  end

  config = YAML.load_file(ARGV[0].to_s)

  source_db_tenants = [config["source_db_tenants"][0], config["source_db_tenants"][1]]
  destination_db_tenant = (config["destination_db_tenant"].nil? or config["destination_db_tenant"] == "null") ? nil : config["destination_db_tenant"]
  source_db_connections = [PG::Connection.open(:dbname => config["source_db_names"][0]), PG::Connection.open(:dbname => config["source_db_names"][1])]
  destination_db_connection = PG::Connection.open(:dbname => config["destination_db_name"])

  violetta_id_map = config["id_maps"][0]

  hashes = create_id_hashes(violetta_id_map)
  violetta_call_to_actions_id_map = hashes[0]
  violetta_users_id_map = hashes[1]

  migrate_db(source_db_connections[1], source_db_tenants[1], destination_db_connection, destination_db_tenant, violetta_call_to_actions_id_map, violetta_users_id_map)

end

main()