#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

# A simple controller not extending ApplicationController to avoid multi tenant management
class HealthCheckController < ActionController::Base
  def health_check
    render :inline => "Healthy."
  end
end
