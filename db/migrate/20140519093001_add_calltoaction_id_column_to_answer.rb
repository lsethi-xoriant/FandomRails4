class AddCalltoactionIdColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :calltoaction_id, :integer
    add_index :answers, :calltoaction_id
  end
end
