class AddIndexOnUserIdInCallToAction < ActiveRecord::Migration
  def change
    add_index :call_to_actions, :user_id
  end
end
