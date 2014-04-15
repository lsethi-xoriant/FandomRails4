class CreateGeneralRewardinUserTable < ActiveRecord::Migration
  def change
    create_table :general_rewarding_users do |t|
    	t.integer :points, default: 0
    	t.references :user

    	t.timestamps
    end
  end
end