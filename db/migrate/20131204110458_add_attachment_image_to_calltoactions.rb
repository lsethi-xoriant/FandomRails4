class AddAttachmentImageToCalltoactions < ActiveRecord::Migration
  def self.up
    change_table :calltoactions do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :calltoactions, :image
  end
end
