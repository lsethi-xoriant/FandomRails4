class CreateUserinteractionsTable < ActiveRecord::Migration
  def change
    create_table :userinteractions do |t|
      t.references :user, :null => false
      t.references :interaction, :null => false
      t.references :answer
      t.integer :counter, default: 1
      t.integer :points, default: 0
      t.integer :added_points, default: 0
      t.timestamps
    end
    add_index :userinteractions, :user_id
    add_index :userinteractions, :interaction_id
    add_index :userinteractions, :answer_id
  end
end
