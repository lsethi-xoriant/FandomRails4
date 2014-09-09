class CreateVoteInteractionTable < ActiveRecord::Migration
   def change
    create_table :votes do |t|
      t.string :title
      t.integer :vote_min, default: 1
      t.integer :vote_max, default: 10
      t.boolean :oneshot
      t.timestamps
    end
  end
end
