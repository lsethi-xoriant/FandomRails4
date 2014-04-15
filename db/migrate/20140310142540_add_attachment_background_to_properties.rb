class AddAttachmentBackgroundToProperties < ActiveRecord::Migration
  def self.up
    change_table :properties do |t|
      t.attachment :background
    end
  end

  def self.down
    drop_attached_file :properties, :background
  end
end
