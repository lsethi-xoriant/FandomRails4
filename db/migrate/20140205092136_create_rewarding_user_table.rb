class CreateRewardingUserTable < ActiveRecord::Migration
  def change
    create_table :rewarding_users do |t|
    	t.integer :points, default: 0
    	t.integer :credits, default: 0  	
    	t.integer :trivia_wrong_counter, default: 0 
    	t.integer :trivia_right_counter, default: 0
    	t.integer :versus_counter, default: 0  	
        t.integer :play_counter, default: 0
        t.integer :like_counter, default: 0
        t.integer :check_counter, default: 0
        t.references :general_rewarding_user
    	t.references :property # Un utente ha un profilo per ogni property.
    	t.references :user

    	t.timestamps
    end
  end
end
