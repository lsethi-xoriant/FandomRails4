#!/bin/env ruby
# encoding: utf-8

require 'rake'
require 'csv'
# require 'ruby-debug'

desc "Export user call to actions leading to specific gallery info to CSV file 
  structured like ['Original file', 'Username', 'Email', 'Releasing file']"

task :export_csv_gallery, [:gallery_tag_name, :csv_file] => :environment do |t, args|
  export_csv_gallery(args[:gallery_tag_name], args[:csv_file])
end

def export_csv_gallery(gallery_tag_name, csv_file)

  switch_tenant("disney")
  start_time = Time.now

  gallery_tag = Tag.find_by_name(gallery_tag_name)

  if gallery_tag.nil?
    puts "No tag with name '#{gallery_tag_name}' found \nExit"
    return
  elsif TagsTag.where(:tag_id => gallery_tag.id, :other_tag_id => Tag.find_by_name("gallery").id).blank?
    puts "WARNING: Tag with name '#{gallery_tag_name}' is not tagged as 'gallery'"
  end

  user_call_to_actions = 
    CallToAction.where("user_id IS NOT NULL AND id IN (#{CallToActionTag.where(:tag_id => gallery_tag.id).pluck(:call_to_action_id).join(",")})")

  puts "#{user_call_to_actions.count} user call to actions to iterate \nRunning..."

  CSV.open(csv_file, "w", { :col_sep => ";" }) do |csv|
    csv << ["Original file", "Username", "Email", "Releasing file"]
    lap_time = Time.now
    user_call_to_actions.each_with_index do |cta, i|
      user = User.find(cta.user_id)
      username = user.username
      email = user.email
      releasing_file = ReleasingFile.find(cta.releasing_file_id).file.url
      
      if cta.media_image_content_type[-3..-1] != "mp4"
        original_file = cta.media_image.url
      else
        media_file_name = "#{user.id}-#{cta.id}-media.mp4"
        original_file = remove_head_slash("#{cta.media_image.path.sub(cta.media_image_file_name, "")}#{media_file_name}")
      end
      csv << [original_file, username, email, releasing_file]
      if (i + 1) % 100 == 0
        puts "#{i + 1} user call to actions iterated in #{Time.now - lap_time} seconds"
        lap_time = Time.now
      end
    end
  end

  puts "All user call to actions iterated in #{Time.now - start_time} seconds"

end
