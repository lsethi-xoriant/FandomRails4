class SyncedLogFile < ActiveRecord::Base
  attr_accessible :pid, :server_hostname, :timestamp
end