class ChangeViewCountersTable < ActiveRecord::Migration
  def change
    rename_column :view_counters, :type, :ref_type
  end
end
