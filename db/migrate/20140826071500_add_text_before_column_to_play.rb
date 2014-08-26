class AddTextBeforeColumnToPlay < ActiveRecord::Migration
  def change
    add_column :plays, :text_before, :string
  end
end
