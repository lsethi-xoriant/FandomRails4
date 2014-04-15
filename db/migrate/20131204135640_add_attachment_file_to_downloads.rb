class AddAttachmentFileToDownloads < ActiveRecord::Migration
  def self.up
    change_table :downloads do |t|
      t.attachment :attachment
    end
  end

  def self.down
    drop_attached_file :downloads, :attachment
  end
end
