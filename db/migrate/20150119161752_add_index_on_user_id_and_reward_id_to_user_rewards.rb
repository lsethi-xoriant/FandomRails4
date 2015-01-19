class AddIndexOnUserIdAndRewardIdToUserRewards < ActiveRecord::Migration
  def change
    add_index :user_rewards, :user_id
    add_index :user_rewards, :reward_id
  end
end
