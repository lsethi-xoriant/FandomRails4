class CreateLikeTable < ActiveRecord::Migration
  def change
    create_table :likes do |t|
    	t.string :title
      	t.timestamps
    end
  end
end