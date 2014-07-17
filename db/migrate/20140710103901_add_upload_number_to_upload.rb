class AddUploadNumberToUpload < ActiveRecord::Migration
  def change
    add_column :uploads, :upload_number, :integer
  end
end
