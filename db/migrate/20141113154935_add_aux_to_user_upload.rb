class AddAuxToUserUpload < ActiveRecord::Migration
  def up
    add_column :user_upload_interactions, :aux, :json
    execute("CREATE INDEX index_user_uploads_on_aux_fields ON user_upload_interactions ((aux->>'extra_fields'))")
  end

  def down
    execute("DROP INDEX index_user_uploads_on_aux_fields")
    remove_column :user_upload_interactions, :aux
  end
end
