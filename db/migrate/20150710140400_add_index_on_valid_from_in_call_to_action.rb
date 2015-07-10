class AddIndexOnValidFromInCallToAction < ActiveRecord::Migration
  def change
    add_index :call_to_actions, :valid_from
  end
end
