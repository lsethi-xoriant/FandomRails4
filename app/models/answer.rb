#!/bin/env ruby
# encoding: utf-8

class Answer < ActiveRecord::Base
  attr_accessible :text, :correct, :quiz_id, :image, :remove_answer, :call_to_action_id,
    :media_data, :media_image, :media_type

  has_attached_file :media_image, :styles => { :large => "600x600#", :medium => "300x300#", :thumb => "100x100#" }
  has_attached_file :image, :styles => { :large => "600x600#", :medium => "300x300#", :thumb => "100x100#" }
  
  belongs_to :quiz
  has_many :user_interactions

  belongs_to :call_to_action

  validates_presence_of :text

  after_update :check_remove_answer

  def image_url
    image.url
  end

  def media_type_enum
    ["IMAGE", "YOUTUBE", "IFRAME", "VOID"]
  end

  def check_remove_answer
  	self.destroy if self.remove_answer
  end

end
