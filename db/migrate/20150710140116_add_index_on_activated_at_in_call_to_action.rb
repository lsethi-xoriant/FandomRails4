class AddIndexOnActivatedAtInCallToAction < ActiveRecord::Migration
  def change
    add_index :call_to_actions, :activated_at
  end
end
