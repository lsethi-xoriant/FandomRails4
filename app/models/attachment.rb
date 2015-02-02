#!/bin/env ruby
# encoding: utf-8

class Attachment < ActiveRecord::Base
  attr_accessible :data

  attr_accessor :destroy_data

  has_attached_file :data, 
    :styles => { 
      :original => "100%", 
      :carousel => "1024x320^", 
      :medium => "524x393^", 
      :thumb => "262x147^" 
    }, 
    :convert_options => { 
      :original => " -quality 60", 
      :carousel => " -crop '1024x320+0+40'", 
      :medium => " -gravity center -crop '524x393+0+0'", 
      :thumb => " -gravity center -crop '262x147+0+0'" 
    }

  def destroy_data=(destroy_data_check)
    self.data.destroy if destroy_data_check == '1'
  end

end
