class AddLinkColumnToShare < ActiveRecord::Migration
  def change
    add_column :shares, :link, :string
  end
end
