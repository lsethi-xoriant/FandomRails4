# Rake task for violetta and disneychannel old fandom

desc "Creates a JSON output file for each model which contains id to attachment_url map."

task :generate_releasing_files_map => :environment do
  generate_releasing_files_map
end

def generate_releasing_files_map
  FileUtils.mkdir_p "files" # mkdir if not existing

  db_name = Rails.configuration.database_configuration[Rails.env]["database"]
  output_file = File.open("files/" + db_name + "_id_to_paperclip_url_for_releasing_files_map.txt", "w") { |file|

    file.truncate(0)
    file.print("{")

    ### USER CTA ###
    file.print(",\n\"user_call_to_actions\":{")

    user_call_to_actions_count = Core::Gallery.all.count
    Core::Gallery.all.each_with_index do |user_call_to_action, i|
      puts "Processing user_call_to_action ##{user_call_to_action.id}\n"
      file.print("\"" + user_call_to_action.id.to_s + "\":{\"user_call_to_action_releasing_file_url\":\"" + user_call_to_action.release.url + "\"")
      i != user_call_to_actions_count - 1 ? file.print("},\n") : file.print("}\n")
    end
    file.print("}\n")
    ### END USER CTA ###

    file.print("}")
  }
end