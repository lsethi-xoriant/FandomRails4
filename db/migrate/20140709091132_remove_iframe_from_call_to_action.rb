class RemoveIframeFromCallToAction < ActiveRecord::Migration
  def up
    remove_column :call_to_actions, :iframe
  end

  def down
    add_column :call_to_actions, :iframe, :text
  end
end
