require 'rake'
require 'csv'

desc "Assign tags to call to actions from csv file - ROW: [cta.description, tag_present.name, tag_to_add.name, comments (ignore)]"

task :assign_tags, [:csv_file] => :environment do |task, args|
  assign_tags(args.csv_file)
end

def assign_tags(csv_file)
  switch_tenant('disney')

  FileUtils.mkdir_p "tag_assignment_files" # mkdir if not existing
  File.open("tag_assignment_files/log.txt", "w") { |file| file.truncate(0) }

  missing_call_to_actions = Array.new
  missing_tags = Array.new
  not_created = Array.new
  not_present = Array.new

  File.open("tag_assignment_files/log.txt", "a") { |file|

    CSV.foreach(csv_file) do |csv_row|
      puts "Analyzing row #{csv_row.inspect}"
      row = eval(csv_row.inspect)
      if csv_row[2] # there are some tags in row
        cta = CallToAction.find_by_description(row[0])
        tags = csv_row[2][0..-2].split(',')
        tags.each do |tag_name|
          tag_name.gsub!(/\s+/, "")
          tag = Tag.find_by_name(tag_name)
          if !tag
            missing_tags << tag_name unless missing_tags.include?(tag_name)
            not_created << [row[0], tag_name]
          elsif !cta
            missing_call_to_actions << row[0] unless missing_call_to_actions.include?(row[0])
            not_created << [row[0], tag_name]
          else
            CallToActionTag.create(call_to_action_id: cta.id, tag_id: tag.id)
            if CallToActionTag.where(call_to_action_id: cta.id, tag_id: tag.id).blank?
              not_present << [row[0], tag_name]
            end
            #puts "Aggiunto il tag #{tag.name} alla cta con nome '#{cta.name}'"
          end
        end
      end
    end

    file.puts("CALL TO ACTION TAG NON CREATI: \n")
    file.puts(not_created)

    file.puts("\n------------------------------------------------------------------------\nTAG MANCANTI: \n")
    file.puts(missing_tags)
    
    file.puts("\n------------------------------------------------------------------------\nCALL TO ACTION MANCANTI: \n")
    file.puts(missing_call_to_actions)

    file.puts("\n------------------------------------------------------------------------\nCALL TO ACTION TAG CON ERRORI IN CREAZIONE: \n")
    file.puts(not_present)
  }

end