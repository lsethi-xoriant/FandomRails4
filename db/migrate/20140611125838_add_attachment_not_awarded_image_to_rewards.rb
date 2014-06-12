class AddAttachmentNotAwardedImageToRewards < ActiveRecord::Migration
  def self.up
    change_table :rewards do |t|
      t.attachment :not_awarded_image
    end
  end

  def self.down
    drop_attached_file :rewards, :not_awarded_image
  end
end
