class AddPeriodIdToUserReward < ActiveRecord::Migration
  def change
    add_column :user_rewards, :period_id, :integer
  end
end
