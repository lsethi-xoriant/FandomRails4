#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class LandingController < ApplicationController

  before_filter :redirect_current_user

  def redirect_current_user
    if current_user
      redirect_to "/" 
    end
  end

  def index
  end

end
