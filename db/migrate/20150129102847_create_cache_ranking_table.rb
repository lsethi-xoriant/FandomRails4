class CreateCacheRankingTable < ActiveRecord::Migration
  def change
    create_table :cache_rankings do |t|
      t.string :name
      t.integer :version
      t.integer :user_id
      t.integer :position
      t.timestamps
    end
    add_column :cache_rankings, :data, :json
    add_index :cache_rankings, :name
    add_index :cache_rankings, :version
    add_index :cache_rankings, :user_id
    add_index :cache_rankings, :position
  end
end
