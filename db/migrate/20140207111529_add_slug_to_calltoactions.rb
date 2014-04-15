class AddSlugToCalltoactions < ActiveRecord::Migration
  def change
    add_column :calltoactions, :slug, :string
    add_index :calltoactions, :slug
  end
end
