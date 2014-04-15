class CreateContestPeriodicityTable < ActiveRecord::Migration
  def change
    create_table :contest_periodicities do |t|
      t.string :title, :null => false
      t.integer :custom_periodicity
      t.references :periodicity_type
      t.references :contest
      t.timestamps
    end
  end
end
