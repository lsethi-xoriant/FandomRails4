class CreateUserRewardsTable < ActiveRecord::Migration
  def change
    create_table :user_rewards do |t|
      t.references :user
      t.references :reward
      t.boolean :available
      t.integer :counter, :default => 0
      t.timestamps
    end
  end
end
