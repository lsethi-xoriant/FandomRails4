class DropTagFieldsTable < ActiveRecord::Migration
  def change
    drop_table :tag_fields
  end
end
