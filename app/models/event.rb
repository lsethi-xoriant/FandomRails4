class Event < ActiveRecord::Base
  attr_accessible :session_id, :pid, :message, :request_uri, :file_name, :method_name, 
    :line_number, :data, :timestamp, :tenant, :level, :user_id

end