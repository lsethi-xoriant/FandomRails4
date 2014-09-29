module BallandoHelper
  
  include PeriodicityHelper
  include ApplicationHelper
  
  def get_superfan_reward
    cache_short("weekly_superfan") do
      Reward.includes({:reward_tags => { :tag => :tag_fields }}).where("tags.name = 'superfan' and rewards.valid_from < ? and rewards.valid_to > ?", Time.now.utc, Time.now.utc).first  
    end
  end
  
end