module BallandoHelper
  
  include PeriodicityHelper
  include ApplicationHelper
  
  def get_superfan_reward
    cache_short("weekly_superfan") do
      Reward.includes({:reward_tags => { :tag => :tag_fields }}).where("tags.name = 'superfan' and rewards.valid_from < ? and rewards.valid_to > ?", Time.now.utc, Time.now.utc).first  
    end
  end


  def always_shown_interactions(calltoaction)
    cache_short("always_shown_interactions") do
      calltoaction.interactions.where("when_show_interaction = ? AND required_to_complete = ?", "SEMPRE_VISIBILE", true).order("seconds ASC").to_a
    end
  end
  
end