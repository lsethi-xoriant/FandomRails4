class AddValidFromAndValidToToTag < ActiveRecord::Migration
  def change
    add_column :tags, :valid_from, :datetime
    add_column :tags, :valid_to, :datetime
  end
end
