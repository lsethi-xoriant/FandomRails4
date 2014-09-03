class RemoveLinkColumnFromShare < ActiveRecord::Migration
  def up
    remove_column :shares, :link
  end

  def down
    add_column :shares, :link, :string
  end
end
