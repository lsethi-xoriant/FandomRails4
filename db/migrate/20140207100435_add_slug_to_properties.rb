class AddSlugToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :slug, :string
    add_index :properties, :slug
  end
end
