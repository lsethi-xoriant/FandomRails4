#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class LandingController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def landing_app
  end

  def landing_tab
  end
end
