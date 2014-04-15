class CreatePromocodeTable < ActiveRecord::Migration
  def change
    create_table :promocodes do |t|
    	t.string :title
    	t.string :code
    	t.references :property
      	t.timestamps
    end
  end
end
