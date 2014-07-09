class AddAttachmentReleasingDocumentToUploads < ActiveRecord::Migration
  def self.up
    change_table :uploads do |t|
      t.attachment :releasing_document
    end
  end

  def self.down
    drop_attached_file :uploads, :releasing_document
  end
end
