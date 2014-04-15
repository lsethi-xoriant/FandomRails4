class DropTableTickets < ActiveRecord::Migration
  def up
    drop_table :tickets
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
