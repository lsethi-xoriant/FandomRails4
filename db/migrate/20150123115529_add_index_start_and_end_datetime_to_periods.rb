class AddIndexStartAndEndDatetimeToPeriods < ActiveRecord::Migration
  def change
    add_index :periods, :start_datetime
    add_index :periods, :end_datetime
  end
end
