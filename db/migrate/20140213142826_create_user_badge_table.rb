class CreateUserBadgeTable < ActiveRecord::Migration
  def change
    create_table :user_badges do |t|
    	t.references :badge
    	t.references :rewarding_user
      	t.timestamps
    end
  end
end