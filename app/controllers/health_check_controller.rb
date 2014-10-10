#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

# A simple controller not extending ApplicationController to avoid multi tenant management
class HealthCheckController < ActionController::Base
  def health_check
    check_log_daemon()
    render :inline => "Healthy."
  end
  
  def check_log_daemon
    pid_file = Rails.root + "tmp/pids/log_daemon_monitor.pid"
    if !File.exists?(pid_file)
      raise Exception.new("log_daemon down: no pid file")
    end
    pid = File.open(pid_file) { |fd| fd.read.to_i }
    if pid == 0
      raise Exception.new("log_daemon down: pid file invalid")
    end
    active = !Sys::ProcTable.ps.index { |process| process.pid == pid }.nil?
    if !active
      raise Exception.new("log_daemon down: process not found")
    end
  end
end
