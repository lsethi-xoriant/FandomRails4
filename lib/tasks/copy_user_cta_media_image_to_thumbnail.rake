#!/bin/env ruby
# encoding: utf-8

require 'rake'

desc "Links user cta media images to thumbnails"

task :fill_user_cta_thumbnails => :environment do |t, args|
  fill_user_cta_thumbnails
end

def fill_user_cta_thumbnails()
  switch_tenant('disney')

  user_ctas = CallToAction.where('user_id IS NOT NULL')
  total = user_ctas.count
  step = (total * 0.05).floor
  exceptions_counter = 0

  puts "#{total} user call to actions to be updated\nRunning task..."
  STDOUT.flush

  user_ctas.each_with_index do |user_cta, i|
    begin
      user_cta.thumbnail = user_cta.media_image
      user_cta.save
    rescue Exception => exception
      exceptions_counter += 1
      puts "Error on user call to action ##{user_cta.id} - #{user_cta.title}:\n #{exception} - #{exception.backtrace[0, 5]}\n"
    end
    if (i + 1) % step == 0
      puts "#{i + 1} call to action updated"
      STDOUT.flush
    end
  end

  puts "\nTask ended. #{total - exceptions_counter} / #{total} user call to action successfully updated\n"

end