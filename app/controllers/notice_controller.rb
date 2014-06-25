#!/bin/env ruby
# encoding: utf-8

class NoticeController < ApplicationController
  
  def mark_as_viewed
    result = Notice.mark_as_viewed(params[:notice_id])
    create_json_response(result)
  end
  
  def mark_as_read
    result = Notice.mark_as_read(params[:notice_id])
    create_json_response(result)
  end
  
  def mark_all_as_viewed
    result = Notice.mark_all_as_viewed()
    create_json_response(result)
  end
  
  def mark_all_as_read
    result = Notice.mark_all_as_read()
    create_json_response(result)
  end
  
  def get_user_latest_notices
    response = Hash.new
    latest_notice = Notice.get_user_latest_notice(current_user, 3)
    response['result'] = latest_notice
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end
  
  def create_json_response(result)
    response = Hash.new
    if result
      response['success'] = true
      response['message'] = ""
    else
      response['success'] = false
      response['message'] = "Errore nell'aggiornamento delle notifiche"
    end
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end

end
