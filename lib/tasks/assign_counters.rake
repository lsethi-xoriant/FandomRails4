require 'rake'

desc "Assign counter rewards to users"

task :assign_counters => :environment do
  assign_counters
end

def assign_counters
  switch_tenant('disney')

  violetta_tag_id = Tag.find_by_name('violetta').id
  max_dc_cta_id = CallToActionTag.where(:tag_id => violetta_tag_id).minimum(:id) - 1

  comment_counter_id = Reward.find_by_name('comment-counter').id
  violetta_comment_counter_id = Reward.find_by_name('violetta-comment-counter').id

  count = 0
  User.find_each do |user|
    total_comment_counter = UserCommentInteraction.where(:user_id => user.id).count
    dc_comment_counter = UserCommentInteraction.joins("join comments on user_comment_interactions.comment_id = comments.id 
                                                      join interactions on interactions.resource_id = comments.id")
                                                      .where("user_comment_interactions.user_id = #{user.id} 
                                                              and interactions.resource_type = 'Comment' 
                                                              and interactions.call_to_action_id <= #{max_dc_cta_id}")
                                                        .count

    UserReward.create(:user_id => user.id, :reward_id => comment_counter_id, :available => true, :counter => dc_comment_counter, :period_id => nil)
    UserReward.create(:user_id => user.id, :reward_id => violetta_comment_counter_id, :available => true, :counter => total_comment_counter - dc_comment_counter, :period_id => nil)

    count += 1
    if count % 1000 == 0
      puts "Counter user rewards assigned to #{count} users"
    end
  end

  puts "Counter user rewards assigned to #{count} users"

end