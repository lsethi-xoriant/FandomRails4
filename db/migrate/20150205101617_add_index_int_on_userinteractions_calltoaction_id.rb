class AddIndexIntOnUserinteractionsCalltoactionId < ActiveRecord::Migration
  def up
    execute("DROP INDEX index_user_interactions_on_aux_call_to_action_id")
    execute("CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions (cast(aux->>'call_to_action_id' AS int));")
  end

  def down
    execute("DROP INDEX index_user_interactions_on_aux_call_to_action_id")
  end
end
