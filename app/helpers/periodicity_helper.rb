#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

module PeriodicityHelper
  
  def get_current_periodicities
    period_list = Hash.new
    periods = Period.where("start_datetime < ? AND end_datetime > ?", Time.now, Time.now)
    periods.each do |period|
      period_list[period.kind] = period
    end
    period_list
  end
  
  def create_weekly_periodicity
    
  end
  
end
