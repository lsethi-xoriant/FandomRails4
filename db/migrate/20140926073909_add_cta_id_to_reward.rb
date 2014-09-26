class AddCtaIdToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :call_to_action_id, :integer
  end
end
