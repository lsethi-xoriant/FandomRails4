class Share < ActiveRecord::Base
  attr_accessible :providers, :picture
  has_attached_file :picture, :styles => { :large => ["600x600", :jpg], :medium => ["234x139>", :jpg], :thumb => ["300x300#", :jpg] }, 
                    :convert_options => { :large => '-quality 60', :medium => '-quality 60', :thumb => '-quality 60' }
  
  has_one :interaction, as: :resource
end
