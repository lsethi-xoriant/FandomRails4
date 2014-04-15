class AddAttachmentImageToPrizes < ActiveRecord::Migration
  def self.up
    change_table :instant_win_prizes do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :instant_win_prizes, :image
  end
end
