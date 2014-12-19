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
    ActiveRecord::Base.transaction do
      if Time.now.utc.in_time_zone($site.timezone).wday >= 6
        start_date = Time.now.utc.in_time_zone($site.timezone).end_of_week - 1
      else
        start_date = Time.now.utc.in_time_zone($site.timezone).beginning_of_week - 2
      end
      end_date = start_date + 6.day
      period = Period.create(kind: PERIOD_KIND_WEEKLY, start_datetime: start_date.beginning_of_day, end_datetime: end_date.end_of_day)
      expire_cache_key("current_periodicities")
      period.id
    end 
  end
  
  def create_daily_periodicity
    ActiveRecord::Base.transaction do
      #today = Date.today
      now = Time.now.utc.in_time_zone($site.timezone)
      period = Period.create(kind: PERIOD_KIND_DAILY, start_datetime: now.beginning_of_day, end_datetime: now.end_of_day)
      expire_cache_key("current_periodicities")
      period.id
    end
  end
  
  def create_monthly_periodicity
    ActiveRecord::Base.transaction do
      start_date = Time.now.utc.in_time_zone($site.timezone).beginning_of_month
      end_date = Time.now.utc.in_time_zone($site.timezone).end_of_month
      period = Period.create(kind: PERIOD_KIND_MONTHLY, start_datetime: start_date.beginning_of_day, end_datetime: end_date.end_of_day)
      expire_cache_key("current_periodicities")
      period.id
    end 
  end
  
end
