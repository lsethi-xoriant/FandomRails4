class AddTimestampIndexAndRequestUriIndexAndMessageIndexToEvent < ActiveRecord::Migration
  def change
    add_index :events, :timestamp
    add_index :events, :request_uri
    add_index :events, :message
  end
end
