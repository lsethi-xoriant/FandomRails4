class CreateCheckTable < ActiveRecord::Migration
  def change
    create_table :checks do |t|
    	t.string :title
    	t.text :description
    	t.timestamps
    end
  end
end