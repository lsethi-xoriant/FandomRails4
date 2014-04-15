class AddAttachmentImageToLevels < ActiveRecord::Migration
  def self.up
    change_table :levels do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :levels, :image
  end
end
