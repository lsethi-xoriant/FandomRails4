class AddAttachmentImageToHomeLaunchers < ActiveRecord::Migration
  def self.up
    change_table :home_launchers do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :home_launchers, :image
  end
end
