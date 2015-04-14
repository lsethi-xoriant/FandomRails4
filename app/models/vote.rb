#!/bin/env ruby
# encoding: utf-8

class Vote < ActiveRecord::Base

	attr_accessible :title, :vote_min, :vote_max, :one_shot, :extra_fields, :subtitle
  attr_accessor :subtitle

	has_one :interaction, as: :resource

	validates_presence_of :vote_min, allow_blank: false
	validates_presence_of :vote_max, allow_blank: false

  before_save :set_subtitle

  def set_subtitle
    if self.subtitle.present?
      write_attribute :extra_fields, { "subtitle" => subtitle }.to_json
      subtitle = nil
    else
      write_attribute :extra_fields, {}.to_json
    end
  end

end
