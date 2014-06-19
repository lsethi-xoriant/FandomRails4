#!/bin/env ruby
# encoding: utf-8

class Answer < ActiveRecord::Base
  attr_accessible :text, :correct, :quiz_id, :image, :remove_answer, :call_to_action_id
  # Non utilizzato come accessor in quanto se veniva modificato solamente quell'elemento non passava per after_update.
  # attr_accessor :remove_answer

  has_attached_file :image, :styles => { :large => "600x600#", :medium => "300x300#", :thumb => "100x100#" }
  
  belongs_to :quiz
  has_many :user_interactions

  belongs_to :call_to_action

  validates_presence_of :text

  after_update :check_remove_answer

  def image_url
    image.url
  end

  def check_remove_answer
  	self.destroy if self.remove_answer
  end

end
