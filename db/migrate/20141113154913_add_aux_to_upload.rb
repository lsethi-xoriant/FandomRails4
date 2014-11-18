class AddAuxToUpload < ActiveRecord::Migration
  def up
    add_column :uploads, :aux, :json
    execute("CREATE INDEX index_uploads_on_aux_fields ON uploads ((aux->>'extra_fields'))")
    execute("DROP INDEX index_call_to_actions_on_aux_options")
    execute("CREATE INDEX index_call_to_actions_on_aux_options ON call_to_actions ((aux->>'share'))")
  end

  def down
    execute("DROP INDEX index_uploads_on_aux_fields")
    remove_column :uploads, :aux
  end
end
