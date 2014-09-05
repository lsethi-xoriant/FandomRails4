class RemoveProviderColumnFromShare < ActiveRecord::Migration
  def up
    remove_column :shares, :providers
  end

  def down
    add_column :shares, :providers, :text
  end
end
