class AddCounterIndexToViewCounter < ActiveRecord::Migration
  def change
    add_index :view_counters, :counter
  end
end
