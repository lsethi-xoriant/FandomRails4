class AddAuxColumnToCallToAction < ActiveRecord::Migration
  def up
    add_column :call_to_actions, :aux, :json
    execute("CREATE INDEX index_call_to_actions_on_aux_options ON user_interactions ((aux->>'share'))")
  end

  def down
    execute("DROP INDEX index_call_to_actions_on_aux_options")
    remove_column :call_to_actions, :aux
  end
end
