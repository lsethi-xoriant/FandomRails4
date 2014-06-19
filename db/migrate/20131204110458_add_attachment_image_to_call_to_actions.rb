class AddAttachmentImageToCallToActions < ActiveRecord::Migration
  def self.up
    change_table :call_to_actions do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :call_to_actions, :image
  end
end
