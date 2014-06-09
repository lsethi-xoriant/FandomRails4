#!/bin/env ruby
# encoding: utf-8

class PropertyController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => :index
  
  def index
    if mobile_device?
      @calltoactions = cache_short { Calltoaction.active.limit(3).to_a }
    else
      @calltoactions = cache_short { Calltoaction.active_no_order.order("activated_at ASC").to_a }
      @calltoactions_comingsoon = cache_short() { Calltoaction.future_no_order.order("activated_at ASC").to_a }
    end
  end

  def extra
    if mobile_device?
      @calltoactions = cache_short { calltoaction_active_with_tag("extra", "DESC").limit(3).to_a }
    else
      @calltoactions = cache_short { calltoaction_active_with_tag("extra", "ASC").to_a }
    end
  end

  def append_calltoaction
    render_calltoaction_str = String.new
    streamcalltoaction = Array.new

    streamcalltoactiontorender = Calltoaction.active.offset(params[:offset]).limit(3)

    if params[:type] == "extra"
      streamcalltoactiontorender = calltoaction_active_with_tag("extra", "DESC").offset(params[:offset]).limit(3)
    else
      streamcalltoactiontorender = calltoaction_active_with_tag("extra", "DESC").offset(params[:offset]).limit(3)
    end
    
    streamcalltoactiontorender.each do |c|
      streamcalltoaction << c
      render_calltoaction_str = render_calltoaction_str + (render_to_string "/calltoaction/_stream_single_calltoaction", locals: { calltoaction: c, type: params[:type] }, layout: false, formats: :html)
    end

    risp = Hash.new
    risp[:streamcalltoaction] = streamcalltoaction
    risp[:html_to_append] = render_calltoaction_str
    respond_to do |format|
      format.json { render json: risp.to_json }
    end
    
  end

end
