class CreateCacheVoteTable < ActiveRecord::Migration
  def change
    create_table :cache_votes do |t|
      t.integer :version
      t.integer :call_to_action_id
      t.integer :vote_count
      t.integer :vote_sum
      t.timestamps
    end

    add_column :cache_votes, :aux, :json, default: '{}'

    add_index :cache_votes, :version
    add_index :cache_votes, :call_to_action_id
  end
end
