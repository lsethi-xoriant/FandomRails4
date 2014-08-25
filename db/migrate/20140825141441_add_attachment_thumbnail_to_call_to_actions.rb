class AddAttachmentThumbnailToCallToActions < ActiveRecord::Migration
  def self.up
    change_table :call_to_actions do |t|
      t.attachment :thumbnail
    end
  end

  def self.down
    drop_attached_file :call_to_actions, :thumbnail
  end
end
