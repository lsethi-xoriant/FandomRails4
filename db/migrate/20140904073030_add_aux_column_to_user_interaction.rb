class AddAuxColumnToUserInteraction < ActiveRecord::Migration
  def up
    add_column :user_interactions, :aux, :json
    execute("CREATE INDEX index_user_interactions_on_aux_share ON user_interactions ((aux->>'share'))")
  end

  def down
    execute("DROP INDEX index_user_interactions_on_aux_share")
    remove_column :user_interactions, :aux
  end
end
