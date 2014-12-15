#!/bin/env ruby
# encoding: utf-8

class Attachment < ActiveRecord::Base
  attr_accessible :data

  attr_accessor :destroy_data

  has_attached_file :data, :styles => { :large => "600x600#", :medium => "300x300#", :thumb => "100x100#" }, 
                    :convert_options => { :large => '-quality 60', :medium => '-quality 60', :thumb => '-quality 60' }

  def destroy_data=(destroy_data_check)
    self.data.destroy if destroy_data_check == '1'
  end

end
