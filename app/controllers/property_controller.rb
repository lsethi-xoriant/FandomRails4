#!/bin/env ruby
# encoding: utf-8

class PropertyController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :index
  
  def index
  end

end
