include PeriodicityHelper

class UserReward < ActiveRecord::Base
  
  attr_accessible :user_id, :reward_id, :available, :counter, :period_id

  belongs_to :user
  belongs_to :reward
  belongs_to :period

  # Returns a list of triples: name, available, counter
  def self.get_rewards_info(user, current_periodicities)
    period_ids = current_periodicities.values.map { |p| p.id }
    
    query_first_part = UserReward.includes(:reward, :period).select("rewards.name, rewards.countable, available, counter, periods.kind")
    if period_ids.any?
      period_id_qmarks = (["?"] * period_ids.count).join(", ") 
      query_first_part.where("user_id = ? and (period_id in (#{period_id_qmarks}) or period_id is null)", user.id, *period_ids)
    else
      query_first_part.where("user_id = ? and period_id is null", user.id)
    end
  end

  def self.unlock_reward(user, reward_name)
    user_reward = get_user_reward(user, reward_name) 
    if user_reward.nil?
      reward = Reward.find_by_name(reward_name)
      return create(:user_id => user_id, :reward_id => reward.id, :available => true, :counter => 0)
    else
      user_reward.update_attributes(:available => true)
      return user_reward
    end
  end

end