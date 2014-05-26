class AddNewColumnToAuthentication < ActiveRecord::Migration
  def change
    add_column :authentications, :new, :boolean
  end
end
