class CreateUserLevelTable < ActiveRecord::Migration
  def change
    create_table :user_levels do |t|
    	t.references :level
    	t.references :rewarding_user
      	t.timestamps
    end
  end
end