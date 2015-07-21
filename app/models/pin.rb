#!/bin/env ruby
# encoding: utf-8

class Pin < ActiveRecord::Base

  attr_accessible :coordinates, :x_coord, :y_coord, :description
  store_accessor :coordinates, :x_coord, :y_coord, :description

  has_one :interaction, as: :resource

  def one_shot
    false
  end

end