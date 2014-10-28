class InstantWinPrize < ActiveRecord::Base
  attr_accessible :title, :description, :image, :contest_periodicity_id
  has_attached_file :image, :styles => { :medium => "400x400>", :thumb => "100x100>" }, 
                    :convert_options => { :medium => '-quality 60', :thumb => '-quality 60' }, 
                    :default_url => ""
  
  belongs_to :contest_periodicity
end