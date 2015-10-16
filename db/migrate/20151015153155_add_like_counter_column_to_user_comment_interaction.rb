class AddLikeCounterColumnToUserCommentInteraction < ActiveRecord::Migration
  def change
    add_column :user_comment_interactions, :like_counter, :integer, default: 0
  end
end
