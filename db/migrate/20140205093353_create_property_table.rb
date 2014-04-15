class CreatePropertyTable < ActiveRecord::Migration
	def change
	  	create_table :properties do |t|
	  		t.text :description
	  		t.datetime :activated_at
	  		t.string :color_code
	    	t.string :name 	
	    	t.timestamps
	    end
	end
end
