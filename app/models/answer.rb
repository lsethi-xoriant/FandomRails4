#!/bin/env ruby
# encoding: utf-8

class Answer < ActiveRecord::Base
  attr_accessible :text, :symbolic_name, :correct, :quiz_id, :image, :remove_answer, :call_to_action_id,
    :media_data, :media_image, :media_type, :blocking, :destroy_image, :destroy_answer

  attr_accessor :destroy_image, :destroy_answer, :symbolic_name

  has_attached_file :media_image, :styles => { :large => "600x600#", :medium => "300x300#", :thumb => "100x100#" }, 
                    :convert_options => { :large => '-quality 60', :medium => '-quality 60', :thumb => '-quality 60' }
  has_attached_file :image, :styles => { :large => "600x600#", :medium => "300x300#", :thumb => "100x100#" }, 
                    :convert_options => { :large => '-quality 60', :medium => '-quality 60', :thumb => '-quality 60' }
  do_not_validate_attachment_file_type :media_image, :image

  belongs_to :quiz
  has_many :user_interactions

  belongs_to :call_to_action

  # validates_presence_of :text

  before_save :set_aux_for_symbolic_name

  def image_url
    image.url
  end

  def media_type_enum
    MEDIA_TYPES
  end

  def destroy_image=(destroy_image_check)
    self.image.destroy if destroy_image_check == '1'
  end

  def destroy_answer=(destroy_answer_check)
    self.mark_for_destruction if destroy_answer_check == '1'
  end

  def answer_with_media?
    media_type.present? && media_type != "VOID"
  end

  def set_aux_for_symbolic_name
    if symbolic_name
      self.aux = {"symbolic_name" => symbolic_name}.to_json
    end
  end

end
