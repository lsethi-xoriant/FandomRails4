require 'rake'
require 'json'
require 'open-uri'

desc "Creates Paperclip attachments from attachment urls map and ids map"

task :create_attachments, [:param1, :param2] => :environment do |t, args|
  create_attachments(args[:param1], args[:param2])
end

def create_attachments(url_map, id_map)
  switch_tenant('disney')

  # Create url map hashes
  puts "Creating url map hashes...\n"
  file = File.open(url_map, "r")
  url_map = file.read
  url_map_hash = JSON.parse(url_map)

  url_map_cta_hash = url_map_hash['call_to_actions']
  url_map_user_cta_hash = url_map_hash['user_call_to_actions']
  url_map_answers_hash = url_map_hash['answers']
  url_map_rewards_hash = url_map_hash['rewarding_prizes']

  # Create id map hashes
  puts "Creating id map hashes...\n"
  file = File.open(id_map, "r")
  id_map = file.read

  cta_substring = id_map.slice(id_map.index("call_to_actions: ")..-1)[17..-1]
  id_map_cta_hash = eval(truncate_end(cta_substring))

  user_cta_substring = id_map.slice(id_map.index("user_call_to_actions: ")..-1)[22..-1]
  id_map_user_cta_hash = eval(truncate_end(user_cta_substring))

  answers_substring = id_map.slice(id_map.index("answers: ")..-1)[9..-1]
  id_map_answers_hash = eval(truncate_end(answers_substring))

  rewards_substring = id_map.slice(id_map.index("rewards: ")..-1)[9..-1]
  id_map_rewards_hash = eval(truncate_end(rewards_substring))

  # Create attachments for answers
  id_map_answers_hash.each do |old_id, new_id|
    puts "Creating attachment for answer #{new_id}\n"
    begin
      url = url_map_answers_hash[old_id.to_s]["answer_image_url"]
      answer = Answer.find(new_id)
      answer.media_image.destroy
      answer.media_image = open(url)
      answer.save

      if answer.errors.first
        puts "Error on answer #{new_id}: #{answer.errors.first}\n"
      end
    rescue Exception => exception
      puts "Error on answer #{new_id}: #{exception} - #{exception.backtrace[0, 5]}\n"
    end
  end

  # Create attachments for call to actions
  id_map_cta_hash.each do |old_id, new_id|
    start_time = Time.now

    url = url_map_cta_hash[old_id.to_s]["cta_image_url"]
    cta = CallToAction.find(new_id)
    cta.thumbnail.destroy
    begin
      cta.thumbnail = open(url)

      url = url_map_cta_hash[old_id.to_s]["post_image_url"]
      if url
        cta.media_image.destroy
        cta.media_image = open(url)
      end
      cta.save
      if cta.errors.first
        puts "Error on call to action #{new_id}: #{cta.errors.first}\n"
      else
        puts "Created attachment for call to action #{new_id}: #{Time.now - start_time}s\n"
      end
    rescue Exception => exception
      puts "Error on call to action #{new_id}: #{exception} - #{exception.backtrace[0, 5]}\n"
   end

  end

  # Create attachments for user call to actions
  id_map_user_cta_hash.each do |old_id, new_id|
    begin
        puts "Creating attachment for user cta #{new_id}\n"

        url = url_map_user_cta_hash[old_id.to_s]["user_call_to_action_image_url"]
        cta = CallToAction.find(new_id)
        cta.media_image.destroy
        cta.media_image = open(url)
        cta.save

        if cta.errors.first
          puts "Error on user_call_to_action #{new_id}: #{cta.errors.first}\n"
        end
    rescue Exception => exception
      puts "Error on user call to action #{new_id}: #{exception} - #{exception.backtrace[0, 5]}\n"
   end
  end

  # Create attachments for rewards
  id_map_rewards_hash.each do |old_prize_id, new_id|
    begin
      puts "Creating attachment for reward #{new_id}\n"

      old_id = old_prize_id.gsub("prize", "")
      url = url_map_rewards_hash[old_id.to_s]["prize_image_url"]
      reward = Reward.find(new_id)
      reward.main_image.destroy
      reward.main_image = open(url)
      reward.save

      if reward.errors.first
        puts "Error on reward #{new_id}: #{reward.errors.first}\n"
      end
    rescue Exception => exception
        puts "Error on reward #{new_id}: #{exception} - #{exception.backtrace[0, 5]}\n"
     end
    end
end

def truncate_end(str)
  str.slice(0..str.index("}"))
end