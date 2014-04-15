class CreateBadgeTable < ActiveRecord::Migration
  def change
    create_table :badges do |t|
    	t.string :name
    	t.string :description
    	t.string :role
    	t.integer :role_value
    	t.references :property
      t.timestamps
    end
  end
end