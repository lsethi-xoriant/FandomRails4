class RemoveImageColumnFromCallToAction < ActiveRecord::Migration
  def up
    drop_attached_file :call_to_actions, :image
  end

  def down
    change_table :call_to_actions do |t|
      t.attachment :image
    end
  end
end