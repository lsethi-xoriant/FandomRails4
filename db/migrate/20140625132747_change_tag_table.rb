class ChangeTagTable < ActiveRecord::Migration
  def change
    rename_column :tags, :text, :name
    add_index :tags, :name, :unique => true
  end
end
