#!/bin/env ruby
# encoding: utf-8

class Vote < ActiveRecord::Base

  	attr_accessible :title, :vote_min, :vote_max, :oneshot
  
  	has_one :interaction, as: :resource

  	validates_presence_of :vote_min, allow_blank: false
  	validates_presence_of :vote_max, allow_blank: false 

end
