class RemoveDeletedFromUserComment < ActiveRecord::Migration
  def up
    remove_column :user_comments, :deleted
  end

  def down
    add_column :user_comments, :deleted, :boolean
  end
end
