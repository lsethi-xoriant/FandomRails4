class AddAuxColumnToInteraction < ActiveRecord::Migration
  def change
    add_column :interactions, :aux, :json
  end
end
