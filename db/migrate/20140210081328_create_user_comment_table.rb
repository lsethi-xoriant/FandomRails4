class CreateUserCommentTable < ActiveRecord::Migration
	def change
	  	create_table :user_comments do |t|
	    	t.references :user
	    	t.references :comment
	    	t.datetime :published_at
	    	t.text :text
	    	t.boolean :deleted, default: false 	
	    	t.timestamps
	    end
	end
end