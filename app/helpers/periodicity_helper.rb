#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

module PeriodicityHelper
  
  def get_current_periodicities
    cache_short("current_periodicities") do
      period_list = Hash.new
      periods = Period.where("start_datetime < ? AND end_datetime > ?", Time.now, Time.now)
      periods.each do |period|
        period_list[period.kind] = period
      end
      period_list
    end
  end
  
  def get_period_by_kind(periodicity_kind)
    period = Period.where("kind = ? and start_datetime < ? AND end_datetime > ?", periodicity_kind, Time.now, Time.now)
    # TODO: send an alert if period are more than one
    if period.any?
      period.first
    else
      nil
    end
  end
  
  def create_weekly_periodicity
    start_date = Date.today.beginning_of_week
    end_date = Date.today.end_of_week
    period = Period.create(kind: PERIOD_KIND_WEEKLY, start_datetime: start_date.beginning_of_day, end_datetime: end_date.end_of_day)
    period.id 
  end
  
  def create_daily_periodicity
    today = Date.today
    period = Period.create(kind: PERIOD_KIND_DAILY, start_datetime: today.beginning_of_day, end_datetime: today.end_of_day)
    period.id 
  end
  
  def create_monthly_periodicity
    start_date = Date.today.beginning_of_month
    end_date = Date.today.end_of_month
    period = Period.create(kind: PERIOD_KIND_MONTHLY, start_datetime: start_date.beginning_of_day, end_datetime: end_date.end_of_day)
    period.id 
  end
  
end
