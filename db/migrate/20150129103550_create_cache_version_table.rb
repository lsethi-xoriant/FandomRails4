class CreateCacheVersionTable < ActiveRecord::Migration
  def change
    create_table :cache_versions do |t|
      t.string :name
      t.integer :version
      t.timestamps
    end
    add_index :cache_versions, :name
    add_index :cache_versions, :version
  end
end