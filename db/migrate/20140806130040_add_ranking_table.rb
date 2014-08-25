class AddRankingTable < ActiveRecord::Migration
  def change
    create_table :rankings do |t|
      t.references :reward, :null => false
      t.string :name
      t.string :title
      t.string :period
      t.timestamps
    end
  end
end
