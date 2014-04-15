class CreateTableInstantWin < ActiveRecord::Migration
  def change
    create_table :instantwins do |t|
      t.references :contest_periodicity, :null => false
      t.datetime :time_to_win, :null => false
      t.string :title
      t.timestamps
    end
  end
end
