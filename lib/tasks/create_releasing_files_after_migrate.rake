require 'rake'
require 'json'
require 'open-uri'

desc "Creates Paperclip attachments from attachment urls map and ids map. 
      Example: create_attachments['/path/to/id_to_paperclip_url_map.txt','/path/to/tables_id_mapping.txt']"

task :create_releasing_files, [:param1, :param2] => :environment do |t, args|
  create_releasing_files(args[:param1], args[:param2])
end

def create_releasing_files(url_map, id_map)
  switch_tenant('disney')

  # Create url map hashes
  puts "Creating url map hash...\n"
  file = File.open(url_map, "r")
  url_map = file.read
  url_map_hash = JSON.parse(url_map)

  url_map_user_cta_hash = url_map_hash['user_call_to_actions']

  # Create id map hashes
  puts "Creating id map hashes...\n"
  file = File.open(id_map, "r")
  id_map = file.read

  user_cta_substring = id_map.slice(id_map.index("user_call_to_actions: ")..-1)[22..-1]
  id_map_user_cta_hash = eval(truncate_end(user_cta_substring))

  # Create attachments for user call to actions
  puts "Creating attachments for user ctas...\n"
  id_map_user_cta_hash.each do |old_id, new_id|
    start_time = Time.now
    begin
      url = url_map_user_cta_hash[old_id.to_s]["user_call_to_action_releasing_file_url"]
      cta = CallToAction.find(new_id)
      rf = ReleasingFile.new
      rf.created_at = cta.created_at
      rf.updated_at = cta.created_at
      rf.file = open(url)
      rf.save
      if rf.errors.first
        puts "Error on saving releasing file for cta #{new_id}: #{rf.errors.first}\n"
      else
        cta.releasing_file_id = rf.id
        cta.save
        if cta.errors.first
          puts "Error on user call to action #{new_id}: #{cta.errors.first}\n"
        else
          puts "Created attachment for user call to action #{new_id}: #{Time.now - start_time}s\n"
        end
      end
    rescue Exception => exception
      puts "Error on user call to action #{new_id}: #{exception} - #{exception.backtrace[0, 5]}\n"
   end
  end
end

def truncate_end(str)
  str.slice(0..str.index("}"))
end