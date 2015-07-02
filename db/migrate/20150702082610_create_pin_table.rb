class CreatePinTable < ActiveRecord::Migration
  def change
    create_table :pins do |t|
      t.timestamps
    end
    add_column :pins, :coordinates, :json
  end
end
