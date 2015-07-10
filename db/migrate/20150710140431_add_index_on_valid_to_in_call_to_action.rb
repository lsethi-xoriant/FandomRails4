class AddIndexOnValidToInCallToAction < ActiveRecord::Migration
  def change
    add_index :call_to_actions, :valid_to
  end
end
