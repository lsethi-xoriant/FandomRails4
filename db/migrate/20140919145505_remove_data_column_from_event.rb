class RemoveDataColumnFromEvent < ActiveRecord::Migration
  def up
    remove_column :events, :data
  end

  def down
    add_column :events, :data, :text
  end
end
