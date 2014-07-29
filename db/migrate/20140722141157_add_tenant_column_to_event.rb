class AddTenantColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :tenant, :string
  end
end
