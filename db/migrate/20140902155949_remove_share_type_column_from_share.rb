class RemoveShareTypeColumnFromShare < ActiveRecord::Migration
  def up
    remove_column :shares, :share_type
  end

  def down
    add_column :shares, :share_type, :string
  end
end
