require 'rake'
require 'json'

desc "Add attachments to extra fields"

task :add_extra_fields_attachments, [:folder] => :environment do |task, args|
  add_extra_fields_attachments(args.folder)
end

def add_extra_fields_attachments(folder)
  switch_tenant('disney')

  Dir.foreach(folder) do |tag_folder|
    next if tag_folder == '.' or tag_folder == '..' or tag_folder == '.DS_Store'

    tag = Tag.find_by_name(tag_folder)
    if tag.nil?
      puts "Tag #{tag_folder} mancante"
    else
      extra_fields = tag.extra_fields.nil? ? {} : JSON.parse(tag.extra_fields)

      Dir.foreach("#{folder}/#{tag_folder}") do |image|
        next if image == '.' or image == '..' or image == '.DS_Store'
        field = File.basename(image, ".*")
        if extra_fields[field].nil?
          puts "extra_field #{field} mancante per il tag #{tag_folder}"
        else
          attachment = Attachment.new
          file = File.open("#{folder}/#{tag_folder}/#{image}")
          attachment.data = file
          file.close
          attachment.save!

          extra_fields[field] = { "type" => "media", "attachment_id" => attachment.id, "url" => attachment.data.url }

          tag.update_attribute(:extra_fields, extra_fields.to_json)
        end

        #my_model_instance = MyModel.new
        #file = File.open(file_path)
        #my_model_instance.attachment = file
        #file.close
        #my_model_instance.save!
      end
    end
  end
end