class AddAttachmentMediaImageToAnswers < ActiveRecord::Migration
  def self.up
    change_table :answers do |t|
      t.attachment :media_image
    end
  end

  def self.down
    drop_attached_file :answers, :media_image
  end
end
