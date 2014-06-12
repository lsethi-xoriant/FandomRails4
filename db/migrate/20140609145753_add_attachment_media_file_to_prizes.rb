class AddAttachmentMediaFileToPrizes < ActiveRecord::Migration
  def self.up
    change_table :rewards do |t|
      t.attachment :media_file
    end
  end

  def self.down
    drop_attached_file :rewards, :media_file
  end
end
