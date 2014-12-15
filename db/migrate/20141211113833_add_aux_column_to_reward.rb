class AddAuxColumnToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :aux, :json
  end
end
