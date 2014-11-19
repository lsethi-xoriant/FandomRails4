class DropPeriodicitiesTypesTable < ActiveRecord::Migration
  def change
    drop_table :periodicity_types
  end
end
