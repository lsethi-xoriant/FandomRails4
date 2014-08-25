class AddPeriodTable < ActiveRecord::Migration
  def change
    create_table :periods do |t|
      t.string :kind
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.timestamps
    end
  end
end
