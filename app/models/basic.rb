#!/bin/env ruby
# encoding: utf-8

class Basic < ActiveRecord::Base

  attr_accessible :basic_type

  has_one :interaction, as: :resource

  def one_shot
    false
  end

end