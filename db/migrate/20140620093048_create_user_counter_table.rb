class CreateUserCounterTable < ActiveRecord::Migration
  def change
    create_table :user_counters do |t|
      t.string :name
      t.integer :correct_answer, default: 0
      t.integer :play, default: 0
      t.references :user
      t.timestamps
    end
  end
end