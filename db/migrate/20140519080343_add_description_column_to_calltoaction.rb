class AddDescriptionColumnToCalltoaction < ActiveRecord::Migration
  def change
    add_column :calltoactions, :description, :text
  end
end
