class AddMediaDataColumnToCallToAction < ActiveRecord::Migration
  def change
    add_column :call_to_actions, :media_data, :text
  end
end
