class CreateCacheVersionTable < ActiveRecord::Migration
  def change
    create_table :cache_versions do |t|
      t.string :name
      t.integer :version
      t.timestamps
    end
    add_column :cache_versions, :data, :json
    add_index :cache_versions, :name
  end
end