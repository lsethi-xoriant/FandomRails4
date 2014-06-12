class AddAttachmentPreviewImageToPrizes < ActiveRecord::Migration
  def self.up
    change_table :rewards do |t|
      t.attachment :preview_image
    end
  end

  def self.down
    drop_attached_file :rewards, :preview_image
  end
end
