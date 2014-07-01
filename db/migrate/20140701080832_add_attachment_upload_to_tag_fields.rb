class AddAttachmentUploadToTagFields < ActiveRecord::Migration
  def self.up
    change_table :tag_fields do |t|
      t.attachment :upload
    end
  end

  def self.down
    drop_attached_file :tag_fields, :upload
  end
end
