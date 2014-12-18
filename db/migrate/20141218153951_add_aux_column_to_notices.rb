class AddAuxColumnToNotices < ActiveRecord::Migration
  def change
    add_column :notices, :aux, :json
  end
end
