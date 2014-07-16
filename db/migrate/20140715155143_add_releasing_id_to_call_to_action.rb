class AddReleasingIdToCallToAction < ActiveRecord::Migration
  def change
    add_column :call_to_actions, :releasing_file_id, :integer
  end
end
