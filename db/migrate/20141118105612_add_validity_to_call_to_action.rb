class AddValidityToCallToAction < ActiveRecord::Migration
  def change
    add_column :call_to_actions, :valid_from, :datetime
    add_column :call_to_actions, :valid_to, :datetime
  end
end
