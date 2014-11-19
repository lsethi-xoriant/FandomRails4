class AddRewardInfoColumnToInstantwin < ActiveRecord::Migration
  def up
    add_column :instantwins, :reward_info, :json
  end

  def down
    remove_column :instantwins, :reward_info
  end
end
