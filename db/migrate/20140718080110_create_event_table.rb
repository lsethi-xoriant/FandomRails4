class CreateEventTable < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :session_id
      t.integer :pid
      t.string :message
      t.string :request_uri
      t.string :file_name
      t.string :method_name
      t.string :line_number
      t.string :params
      t.text :data
      t.string :timestamp
      t.string :event_hash
      t.string :level
    end
  end
end