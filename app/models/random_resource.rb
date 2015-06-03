#!/bin/env ruby
# encoding: utf-8

class RandomResource < ActiveRecord::Base

  attr_accessible :tag

  has_one :interaction, as: :resource

end