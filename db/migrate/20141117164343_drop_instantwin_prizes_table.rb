class DropInstantwinPrizesTable < ActiveRecord::Migration
  def change
    drop_table :instant_win_prizes
  end
end
