class CreatePlayTicketEvents < ActiveRecord::Migration
  def change
    create_table :playticket_events do |t|
    	t.references :user
    	t.references :contest_periodicity
    	t.integer :points_spent
    	t.datetime :used_at
    	t.boolean :winner, :default => false
    	t.timestamps
    end
  end
end
