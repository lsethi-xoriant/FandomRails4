class RemoveMessageColumnFromShare < ActiveRecord::Migration
  def up
    remove_column :shares, :message
  end

  def down
    add_column :shares, :message, :string
  end
end
