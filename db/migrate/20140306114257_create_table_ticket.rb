class CreateTableTicket < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.references :user, :null => false
      t.references :userinteraction, :null => false
      t.references :instantwin
      t.boolean :used, :default => false
      t.datetime :used_at
      t.boolean :winner, :default => false
      t.timestamps
    end
    add_index :tickets, :user_id
    add_index :tickets, :userinteraction_id
  end
end
