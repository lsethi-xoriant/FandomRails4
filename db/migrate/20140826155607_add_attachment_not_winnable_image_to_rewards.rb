class AddAttachmentNotWinnableImageToRewards < ActiveRecord::Migration
  def self.up
    change_table :rewards do |t|
      t.attachment :not_winnable_image
    end
  end

  def self.down
    drop_attached_file :rewards, :not_winnable_image
  end
end
