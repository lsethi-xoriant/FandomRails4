class AddAttachmentMainImageToPrizes < ActiveRecord::Migration
  def self.up
    change_table :rewards do |t|
      t.attachment :main_image
    end
  end

  def self.down
    drop_attached_file :rewards, :main_image
  end
end
