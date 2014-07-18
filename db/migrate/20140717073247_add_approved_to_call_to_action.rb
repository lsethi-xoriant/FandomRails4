class AddApprovedToCallToAction < ActiveRecord::Migration
  def change
    add_column :call_to_actions, :approved, :boolean, :default => nil
  end
end
