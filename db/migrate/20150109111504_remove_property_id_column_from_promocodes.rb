class RemovePropertyIdColumnFromPromocodes < ActiveRecord::Migration
  def up
    remove_column :promocodes, :property_id
  end

  def down
    add_column :promocodes, :property_id, :integer
  end
end
