#!/bin/env ruby
# encoding: utf-8

class PropertyController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :index
  
  def index
    if mobile_device?
      @calltoactions = Calltoaction.active.limit(3)
    else
      @calltoactions = Calltoaction.active_no_order.order("activated_at ASC")
    end
  end

  def append_calltoaction
    render_calltoaction_str = String.new
    streamcalltoaction = Array.new

    streamcalltoactiontorender = Calltoaction.active.offset(params[:offset]).limit(3)
    
    streamcalltoactiontorender.each do |c|
      streamcalltoaction << c
      render_calltoaction_str = render_calltoaction_str + (render_to_string "/calltoaction/_stream_single_calltoaction", locals: { calltoaction: c }, layout: false, formats: :html)
    end

    risp = Hash.new
    risp[:streamcalltoaction] = streamcalltoaction
    risp[:html_to_append] = render_calltoaction_str
    respond_to do |format|
      format.json { render json: risp.to_json }
    end
    
  end

end
