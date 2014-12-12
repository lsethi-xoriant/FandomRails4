class AddExtraFieldsToTag < ActiveRecord::Migration
  def up
    add_column :tags, :extra_fields, :json, default: '{}'
  end

  def down
    remove_column :tags, :extra_fields
  end
end
