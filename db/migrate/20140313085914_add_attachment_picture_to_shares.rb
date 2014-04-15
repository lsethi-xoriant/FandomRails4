class AddAttachmentPictureToShares < ActiveRecord::Migration
  def self.up
    change_table :shares do |t|
      t.attachment :picture
    end
  end

  def self.down
    drop_attached_file :shares, :picture
  end
end
