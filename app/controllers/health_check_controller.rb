#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'
require 'sys/proctable'

# A simple controller not extending ApplicationController to avoid multi tenant management
class HealthCheckController < ActionController::Base
  def health_check
    check_log_daemon()
    render :inline => "Healthy."
  end
  
  def check_log_daemon
    unless Sys::ProcTable.ps.any? { |process| process.cmdline.include?("log_daemon") }
      raise Exception.new("log_daemon seems down")
    end
  end
end
