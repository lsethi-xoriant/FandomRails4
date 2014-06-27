class AddIframeColumnToCallToAction < ActiveRecord::Migration
  def change
    add_column :call_to_actions, :iframe, :text
  end
end
