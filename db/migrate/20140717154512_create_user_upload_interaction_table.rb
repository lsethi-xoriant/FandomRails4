class CreateUserUploadInteractionTable < ActiveRecord::Migration
  def change
    create_table :user_upload_interactions do |t|
      t.references :user, :null => false
      t.references :call_to_action, :null => false
      t.references :upload, :null => false
      t.timestamps
    end
  end
end
