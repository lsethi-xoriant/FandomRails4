class AddAttachmentMediaImageToCallToActions < ActiveRecord::Migration
  def self.up
    change_table :call_to_actions do |t|
      t.attachment :media_image
    end
  end

  def self.down
    drop_attached_file :call_to_actions, :media_image
  end
end
