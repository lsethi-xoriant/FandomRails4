class CreateAttachmentTable < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.timestamps
    end
  end
end
