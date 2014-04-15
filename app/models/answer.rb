#!/bin/env ruby
# encoding: utf-8

class Answer < ActiveRecord::Base
  attr_accessible :text, :correct, :quiz_id, :image, :remove_answer
  # Non utilizzato come accessor in quanto se veniva modificato solamente quell'elemento non passava per after_update.
  # attr_accessor :remove_answer

  has_attached_file :image, :styles => { :large => "600x600", :medium => "234x139>", :thumb => "100x100>" }
  
  belongs_to :quiz
  has_many :userinteractions

  validates_presence_of :text

  after_update :check_remove_answer

  def image_url
    image.url
  end

  def check_remove_answer
  	self.destroy if self.remove_answer
  end

end
