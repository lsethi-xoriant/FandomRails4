class AddOrderingColumnToInteractionCallToAction < ActiveRecord::Migration
  def change
  	add_column :interaction_call_to_actions, :ordering, :integer
  end
end
