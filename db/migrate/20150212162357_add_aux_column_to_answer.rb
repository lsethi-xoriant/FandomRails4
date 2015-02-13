class AddAuxColumnToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :aux, :json
  end
end
