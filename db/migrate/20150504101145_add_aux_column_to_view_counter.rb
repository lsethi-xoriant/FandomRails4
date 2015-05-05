class AddAuxColumnToViewCounter < ActiveRecord::Migration
  def change
    add_column :view_counters, :aux, :json
  end
end
