class CreateInstantWinPrizesTable < ActiveRecord::Migration
  def change
    create_table :instant_win_prizes do |t|
      t.string :title, :null => false
      t.text :description
      t.references :contest_periodicity
      t.timestamps
    end
  end
end
