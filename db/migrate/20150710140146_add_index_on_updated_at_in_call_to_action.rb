class AddIndexOnUpdatedAtInCallToAction < ActiveRecord::Migration
  def change
    add_index :call_to_actions, :updated_at
  end
end
