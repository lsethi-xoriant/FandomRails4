class Share < ActiveRecord::Base
  attr_accessible :providers, :picture
  has_attached_file :picture, :styles => { :large => "600x600", :medium => "234x139>", :thumb => "300x300#" }, 
                    :convert_options => { :large => '-quality 60', :medium => '-quality 60', :thumb => '-quality 60' }
  do_not_validate_attachment_file_type :picture
  
  has_one :interaction, as: :resource

  def one_shot
    false
  end
end
