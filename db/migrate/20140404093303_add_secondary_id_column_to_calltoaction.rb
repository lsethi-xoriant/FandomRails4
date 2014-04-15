class AddSecondaryIdColumnToCalltoaction < ActiveRecord::Migration
  def change
    add_column :calltoactions, :secondary_id, :string
  end
end
