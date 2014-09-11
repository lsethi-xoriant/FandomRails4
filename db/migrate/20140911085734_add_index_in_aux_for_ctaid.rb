class AddIndexInAuxForCtaid < ActiveRecord::Migration
  def up
    execute("CREATE INDEX index_user_interactions_on_aux_call_to_action_id ON user_interactions ((aux->>'call_to_action_id'))")
  end

  def down
    execute("DROP INDEX index_user_interactions_on_aux_call_to_action_id")
  end
end
