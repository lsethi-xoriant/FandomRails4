#!/bin/env ruby
# encoding: utf-8

class ViewCounter < ActiveRecord::Base
  attr_accessible :type, :ref_id, :ref_type, :counter, :aux
end
