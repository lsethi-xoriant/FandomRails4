class AddExtraFieldsToReward < ActiveRecord::Migration
  def up
    add_column :rewards, :extra_fields, :json, default: '{}'
  end

  def down
    remove_column :rewards, :extra_fields
  end
end
