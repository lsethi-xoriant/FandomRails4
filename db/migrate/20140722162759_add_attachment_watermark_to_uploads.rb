class AddAttachmentWatermarkToUploads < ActiveRecord::Migration
  def self.up
    change_table :uploads do |t|
      t.attachment :watermark
    end
  end

  def self.down
    drop_attached_file :uploads, :watermark
  end
end
