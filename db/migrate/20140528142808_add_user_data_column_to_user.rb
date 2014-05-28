class AddUserDataColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :cap, :string
    add_column :users, :location, :string
    add_column :users, :province, :string
    add_column :users, :address, :string
    add_column :users, :phone, :string
    add_column :users, :number, :string
    add_column :users, :rule, :boolean
    add_column :users, :birth_date, :date
  end
end
