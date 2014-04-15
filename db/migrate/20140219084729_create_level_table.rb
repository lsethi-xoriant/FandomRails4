class CreateLevelTable < ActiveRecord::Migration
  def change
    create_table :levels do |t|
    	t.string :name
    	t.string :description
    	t.integer :points
    	t.references :property
      	t.timestamps
    end
  end
end