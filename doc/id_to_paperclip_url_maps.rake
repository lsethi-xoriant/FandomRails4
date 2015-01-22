# Rake task for violetta and disneychannel old fandom

desc "Creates a JSON output file for each model which contains id to attachment_url map."

task :generate_maps => :environment do
  generate_maps
end

def generate_maps
  FileUtils.mkdir_p "files" # mkdir if not existing

  db_name = Rails.configuration.database_configuration[Rails.env]["database"]
  output_file = File.open("files/" + db_name + "_id_to_paperclip_url_map.txt", "w") { |file|

    file.truncate(0)
    file.print("{")

    ### CTA ###
    file.print("\"call_to_actions\":{")

    cta_count = Experience::CallToAction.all.count
    Experience::CallToAction.all.each_with_index do |cta, i|
      puts "Processing cta ##{cta.id}\n"
      file.print("\"" + cta.id.to_s + "\":{\"cta_image_url\":\"" + cta.cta_image.url + "\"")
      if cta.contents
        content = cta.contents.first
        if content.cnt_type == 'Experience::PostContent'
          post_image = Experience::PostContent.find(content.cnt_id).post_image.url
          if post_image
            file.print(", \"post_image_url\":\"" + cta.cta_image.url + "\"")
          end
        end
      end
      i != cta_count - 1 ? file.print("},\n") : file.print("}\n")
    end
    file.print("}\n")
    ### END CTA ###

    ### USER CTA ###
    file.print(",\n\"user_call_to_actions\":{")

    user_call_to_actions_count = Core::Gallery.all.count
    Core::Gallery.all.each_with_index do |user_call_to_action, i|
      puts "Processing user_call_to_action ##{user_call_to_action.id}\n"
      file.print("\"" + user_call_to_action.id.to_s + "\":{\"user_call_to_action_image_url\":\"" + user_call_to_action.picture.url + "\"")
      i != user_call_to_actions_count - 1 ? file.print("},\n") : file.print("}\n")
    end
    file.print("}\n")
    ### END USER CTA ###

    ### ANSWERS ###
    file.print(",\n\"answers\":{")

    answers_count = Experience::QuizAnswer.all.count
    Experience::QuizAnswer.all.each_with_index do |answer, i|
      puts "Processing answer ##{answer.id}\n"
      file.print("\"" + answer.id.to_s + "\":{\"answer_image_url\":\"" + answer.answer_image.url + "\"")
      i != answers_count - 1 ? file.print("},\n") : file.print("}\n")
    end
    file.print("}\n")
    ### END ANSWERS ###

    ### PRIZES ###
    file.print(",\n\"rewarding_prizes\":{")

    prizes_count = Rewarding::Prize.all.count
    Rewarding::Prize.all.each_with_index do |prize, i|
      puts "Processing rewarding prize ##{prize.id}\n"
      file.print("\"" + prize.id.to_s + "\":{\"prize_image_url\":\"" + prize.prize_image.url + "\"")
      i != prizes_count - 1 ? file.print("},\n") : file.print("}\n")
    end
    file.print("}\n")
    ### END PRIZES ###

    file.print("}")
  }
end