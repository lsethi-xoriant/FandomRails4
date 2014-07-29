class CreateSyncedLogFileTable < ActiveRecord::Migration
  def change
    create_table :synced_log_files do |t|
      t.string :pid
      t.string :server_hostname
      t.datetime :timestamp
    end
    add_index :synced_log_files, [:pid, :server_hostname, :timestamp], unique: true
  end
end