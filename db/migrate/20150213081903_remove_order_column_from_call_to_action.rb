class RemoveOrderColumnFromCallToAction < ActiveRecord::Migration
  def up
    remove_column :call_to_actions, :order
  end

  def down
    add_column :call_to_actions, :order, :integer
  end
end
