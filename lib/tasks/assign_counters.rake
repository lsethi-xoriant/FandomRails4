require 'rake'

desc "Assign counter rewards to users"

task :assign_counters => :environment do
  assign_counters
end

def assign_counters
  switch_tenant('disney')

  violetta_tag_id = Tag.find_by_name('violetta').id
  max_dc_cta_id = CallToActionTag.where("tag_id = #{violetta_tag_id} AND call_to_action_id > 20").minimum(:call_to_action_id) - 1

  comment_counter_id = Reward.find_by_name('comment-counter').id
  violetta_comment_counter_id = Reward.find_by_name('violetta-comment-counter').id

  user_ids_dc_comments_hash = UserCommentInteraction.joins("join interactions on comment_id = interactions.resource_id")
                              .where("resource_type = 'Comment' and call_to_action_id <= #{max_dc_cta_id}")
                              .group("user_comment_interactions.user_id")
                              .count

  user_ids_violetta_comments_hash = UserCommentInteraction.joins("join interactions on comment_id = interactions.resource_id")
                              .where("resource_type = 'Comment' and call_to_action_id > #{max_dc_cta_id}")
                              .group("user_comment_interactions.user_id")
                              .count

  count = 0
  start_time = Time.now()

  puts "Deleting existing comment counters..."
  destroyed = UserReward.where("reward_id = #{comment_counter_id} or reward_id = #{violetta_comment_counter_id}").destroy_all
  puts "#{destroyed.length} comment counters deleted. \nCounter user rewards is being assigned..."

  user_ids_dc_comments_hash.each do |user_id, dc_comments|

    UserReward.create(:user_id => user_id, :reward_id => comment_counter_id, :available => true, :counter => dc_comments, :period_id => nil)

    count += 1
    if count % 5000 == 0
      puts "Disney-channel counter user rewards assigned to #{count} users. Elapsed time: #{Time.now - start_time}s"
    end
  end

  count = 0

  user_ids_violetta_comments_hash.each do |user_id, violetta_comments|

    UserReward.create(:user_id => user_id, :reward_id => violetta_comment_counter_id, :available => true, :counter => violetta_comments, :period_id => nil)

    count += 1
    if count % 5000 == 0
      puts "Violetta counter user rewards assigned to #{count} users. Elapsed time: #{Time.now - start_time}s"
    end
  end

  puts "\nAll counter user rewards assigned to all users. Elapsed time: #{Time.now - start_time}s"

end