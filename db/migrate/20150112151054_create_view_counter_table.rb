class CreateViewCounterTable < ActiveRecord::Migration
  def change
    create_table :view_counters do |t|
      t.timestamps
      t.string :type
      t.integer :ref_id
      t.integer :counter
    end

    add_index :view_counters, :type
    add_index :view_counters, :ref_id
  end
end
