class AddIndexLikeToUserInteraction < ActiveRecord::Migration
  def up
    execute("CREATE INDEX index_user_interactions_on_aux_like ON user_interactions ((aux->>'like'))")
  end

  def down
    execute("DROP INDEX index_user_interactions_on_aux_like")
  end
end
