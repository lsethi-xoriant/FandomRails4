class DropContestOldTable < ActiveRecord::Migration
  def change
    drop_table :contests
    drop_table :contest_periodicities
    drop_table :contest_points
    drop_table :contest_tags
    drop_table :playticket_events
  end
end
