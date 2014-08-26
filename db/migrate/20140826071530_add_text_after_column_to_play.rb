class AddTextAfterColumnToPlay < ActiveRecord::Migration
  def change
    add_column :plays, :text_after, :string
  end
end
