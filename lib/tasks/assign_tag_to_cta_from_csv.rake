require 'rake'
require 'csv'

desc "Assign tags to call to actions from csv file - ROW: [cta.description, tag_present.name (ignore), tag_to_add.name, comments (ignore)]"

task :assign_tags, [:csv_file] => :environment do |task, args|
  assign_tags(args.csv_file)
end

def assign_tags(csv_file)

  switch_tenant('disney')

  missing_call_to_actions = Array.new
  missing_tags = Array.new
  not_created = Array.new
  not_present = Array.new
  count = 0

  cta_tags_array = CSV.read(csv_file)
  puts "#{cta_tags_array.count} lines to iterate...\n"

  # Hash creation
  tags_hash = Hash.new

  while !cta_tags_array.blank?
    tags_list = Array.new
    line = cta_tags_array.shift # pops from top
    title = CallToAction.connection.quote_string(line[0].rstrip)

    if line[2]
      line[2].split(',').each do |tag|
        tags_list << tag
      end
    end

    # CSV generated array iteration
    cta_tags_array.delete_if do |csv_line|
      if CallToAction.connection.quote_string(csv_line[0].rstrip) == title and csv_line[2]
        csv_line[2].split(',').each do |tag|
          tags_list << tag unless tags_list.include?(tag)
        end
      true
      end
    end
    tags_hash[title] = tags_list

    ctas = CallToAction.where("title ilike '%#{title}%'")
    unless ctas.blank?
      ctas.each do |cta|
        tags_hash[title].each do |tag_name|
          tag = Tag.find_by_name(tag_name)
          if tag
            CallToActionTag.create(call_to_action_id: cta.id, tag_id: tag.id) if CallToActionTag.where(:call_to_action_id => cta.id, :tag_id => tag.id).count == 0
            if CallToActionTag.where(:call_to_action_id => cta.id, :tag_id => tag.id).blank?
              not_present << [cta.title, tag.name]
            else
              count += 1
            end
          end
          missing_tags << tag_name if tag.nil? and !missing_tags.include?(tag_name)
        end
      end
    else
      missing_call_to_actions << title
    end
  end # while

  puts "#{count} call to action tags created"
  puts "Call to action missing: #{missing_call_to_actions}\n-----------------------------------\n" unless missing_call_to_actions.blank?
  puts "Tags missing: #{missing_tags}\n-----------------------------------\n" unless missing_tags.blank?
  puts "Call to action tags creation error for: #{not_present}\n" unless not_present.blank?

end