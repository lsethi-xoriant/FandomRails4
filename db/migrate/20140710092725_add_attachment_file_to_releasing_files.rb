class AddAttachmentFileToReleasingFiles < ActiveRecord::Migration
  def self.up
    change_table :releasing_files do |t|
      t.attachment :file
    end
  end

  def self.down
    drop_attached_file :releasing_files, :file
  end
end
