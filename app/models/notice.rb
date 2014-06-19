class Notice < ActiveRecord::Base
  attr_accessible :user_id, :html_notice, :last_sent, :viewed, :read, :created_at, :updated_at
  
  belongs_to :user
  
end
