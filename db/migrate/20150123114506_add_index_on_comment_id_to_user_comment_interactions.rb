class AddIndexOnCommentIdToUserCommentInteractions < ActiveRecord::Migration
  def change
    add_index :user_comment_interactions, :comment_id
  end
end
