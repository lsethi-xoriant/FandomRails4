class AddProviderColumnToShare < ActiveRecord::Migration
  def change
    add_column :shares, :providers, :json
  end
end
