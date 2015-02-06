class AddGalleryNameColumnToCacheVotes < ActiveRecord::Migration
  def change
    add_column :cache_votes, :gallery_name, :text
  end
end
