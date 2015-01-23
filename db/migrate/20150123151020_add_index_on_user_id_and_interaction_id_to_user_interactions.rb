class AddIndexOnUserIdAndInteractionIdToUserInteractions < ActiveRecord::Migration
  def change
  	add_index :user_interactions, :user_id
    add_index :user_interactions, :interaction_id
  end
end