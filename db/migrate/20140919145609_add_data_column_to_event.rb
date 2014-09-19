class AddDataColumnToEvent < ActiveRecord::Migration
  def change
    add_column :events, :data, :json
  end
end
