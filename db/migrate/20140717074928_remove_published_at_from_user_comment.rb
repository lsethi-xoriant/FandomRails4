class RemovePublishedAtFromUserComment < ActiveRecord::Migration
  def up
    remove_column :user_comments, :published_at
  end

  def down
    add_column :user_comments, :published_at, :datetime
  end
end
