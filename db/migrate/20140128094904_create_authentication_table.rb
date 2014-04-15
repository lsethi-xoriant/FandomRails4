class CreateAuthenticationTable < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
    	# oauth_secret e avatar per twitter.
    	t.string :uid, :name, :oauth_token, :oauth_secret, :provider, :avatar
    	t.datetime :oauth_expires_at
    	t.references :user
    	t.timestamps
    end
    add_index :authentications, :user_id
  end
end