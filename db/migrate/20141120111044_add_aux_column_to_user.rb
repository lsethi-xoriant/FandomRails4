class AddAuxColumnToUser < ActiveRecord::Migration
  def change
    add_column :users, :aux, :json
  end
end
