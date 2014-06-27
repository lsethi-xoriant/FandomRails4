class AddDescriptionAndLockedToTag < ActiveRecord::Migration
  def change
    add_column :tags, :description, :text
    add_column :tags, :locked, :boolean
  end
end
