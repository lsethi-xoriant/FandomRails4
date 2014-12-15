class AddExtraFieldsToCallToAction < ActiveRecord::Migration
  def up
    add_column :call_to_actions, :extra_fields, :json, default: '{}'
  end

  def down
    remove_column :call_to_actions, :extra_fields
  end
end
