class AddInstantwinIdToPlayticket < ActiveRecord::Migration
  def change
  	add_column :playticket_events, :instantwin_id, :integer
  end
end
