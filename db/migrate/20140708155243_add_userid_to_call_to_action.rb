class AddUseridToCallToAction < ActiveRecord::Migration
  def change
    add_column :call_to_actions, :user_generated, :boolean
  end
end
