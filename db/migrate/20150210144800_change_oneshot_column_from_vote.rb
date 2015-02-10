class ChangeOneshotColumnFromVote < ActiveRecord::Migration
  def change
	rename_column :votes, :oneshot, :one_shot    
  end
end
