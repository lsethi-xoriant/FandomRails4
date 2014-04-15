class CreatePlaysTable < ActiveRecord::Migration
  def change
    create_table :plays do |t|
    	t.string :title
      	t.timestamps
    end
  end
end