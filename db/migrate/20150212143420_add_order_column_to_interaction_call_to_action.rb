class AddOrderColumnToInteractionCallToAction < ActiveRecord::Migration
  def change
    add_column :call_to_actions, :order, :integer
  end
end
