class RemoveVideoUrlFromCallToAction < ActiveRecord::Migration
  def up
    remove_column :call_to_actions, :video_url
  end

  def down
    add_column :call_to_actions, :video_url, :string
  end
end
