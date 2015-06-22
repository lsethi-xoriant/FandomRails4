#!/bin/env ruby
# encoding: utf-8

class Attachment < ActiveRecord::Base
  attr_accessible :data

  attr_accessor :destroy_data

  do_not_validate_attachment_file_type :data

  has_attached_file :data, 
    styles: lambda { |image| 
      if image.content_type =~ %r{^(image|(x-)?application)/(x-png|pjpeg|jpeg|jpg|png|gif)$}
        {
          :carousel => { convert_options: "-gravity north -thumbnail 1024x320^ -extent 1024x320" }, 
          :medium => { convert_options: "-gravity north -thumbnail 524x393^ -extent 524x393" }, 
          :thumb => { convert_options: "-gravity north -thumbnail 262x147^ -extent 262x147" }
        }
      elsif image.content_type =~ %r{^(image|(x-)?application)/(pdf)$}
        { }
      else
        { }
      end 
    }, 
    source_file_options:  { all: '-background transparent' }

  def destroy_data=(destroy_data_check)
    self.data.destroy if destroy_data_check == '1'
  end

end
