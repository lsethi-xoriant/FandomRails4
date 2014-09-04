class RemoveDescriptionColumnFromShare < ActiveRecord::Migration
  def up
    remove_column :shares, :description
  end

  def down
    add_column :shares, :description, :string
  end
end
