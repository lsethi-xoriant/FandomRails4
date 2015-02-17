require 'rake'
require 'ruby-debug'
require 'open-uri'

desc "Refresh disney call to action images to new style 'extra_large'"

task :refresh_disney_cta_images => :environment do 
  refresh_disney_cta_images()
end

def refresh_disney_cta_images
  Apartment::Tenant.switch('disney')

  start_time = Time.now
  count = 0
  image_missing = 0
  
  CallToAction.all.each do |cta|
    begin
      if cta.media_image.exists?
        cta.media_image.reprocess! :extra_large
        count += 1
      else
        image_missing += 1
      end
    rescue Exception => exception
      puts "Error on user call to action #{cta.id}: #{exception} - #{exception.backtrace}\n"
    end
    puts "#{count + image_missing} call to action processed" if count % 100 == 0 and count != 0
  end
  puts "#{count} media_images updated in #{Time.now - start_time} seconds; #{image_missing} call to actions without media_image"
end