class AddAuxColumnToAuthentication < ActiveRecord::Migration
  def change
    add_column :authentications, :aux, :json
  end
end
