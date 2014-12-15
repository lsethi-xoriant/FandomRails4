class AddAttachmentDataToAttachments < ActiveRecord::Migration
  def self.up
    change_table :attachments do |t|
      t.attachment :data
    end
  end

  def self.down
    drop_attached_file :attachments, :data
  end
end
