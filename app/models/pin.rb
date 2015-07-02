#!/bin/env ruby
# encoding: utf-8

class Pin < ActiveRecord::Base

  attr_accessible :coordinates, :x_coord, :y_coord, :description
  attr_accessor :x_coord, :y_coord, :description

  has_one :interaction, as: :resource
  before_validation :set_pin_attributes

  def one_shot
    false
  end

  def set_pin_attributes
    write_attribute :coordinates, { "x_coord" => x_coord, "y_coord" => y_coord, "description" => description }.to_json
    x_coord = y_coord = description = nil
  end

end