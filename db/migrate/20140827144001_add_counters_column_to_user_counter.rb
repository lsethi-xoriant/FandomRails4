class AddCountersColumnToUserCounter < ActiveRecord::Migration
  def change
    add_column :user_counters, :counters, :json
  end
end
