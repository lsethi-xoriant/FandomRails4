class AddCallToActionIdColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :call_to_action_id, :integer
    add_index :answers, :call_to_action_id
  end
end
