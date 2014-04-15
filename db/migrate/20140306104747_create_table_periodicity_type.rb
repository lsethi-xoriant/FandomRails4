class CreateTablePeriodicityType < ActiveRecord::Migration
  def change
    create_table :periodicity_types do |t|
      t.string :name, :null => false
      t.integer :period
      t.timestamps
    end
  end
end
