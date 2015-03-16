class AddIndexInUserCommentInteraction < ActiveRecord::Migration
  def up
    execute("CREATE INDEX index_user_comment_interactions_on_approved ON user_comment_interactions (approved)")
    execute("CREATE INDEX index_user_comment_interactions_on_created_at ON user_comment_interactions (created_at)")
  end

  def down
    execute("DROP INDEX index_user_comment_interactions_on_approved")
    execute("DROP INDEX index_user_comment_interactions_on_created_at")
  end
end
