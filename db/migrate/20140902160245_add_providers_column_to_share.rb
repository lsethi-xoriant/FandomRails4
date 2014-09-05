class AddProvidersColumnToShare < ActiveRecord::Migration
  def change
    add_column :shares, :providers, :text
  end
end
