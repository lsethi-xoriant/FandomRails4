#!/bin/env ruby
# encoding: utf-8

class ProfileController < ApplicationController
  include ProfileHelper
  include ApplicationHelper

  def index
  end

  def remove_provider
  	auth = current_user.authentications.find_by_provider(params[:provider])
  	auth.destroy if auth
  	redirect_to "/profile/edit"
  end

  def rankings
  end

  def levels
  end

  def badges
  end
  
  def prizes
    # TODO: adjust.
  end
  
  def notices
    Notice.mark_all_as_viewed()
    notices = Notice.where("user_id = ?", current_user.id).order("created_at DESC")
    @notices_list = group_notice_by_date(notices)
  end
  
  def group_notice_by_date(notices)
    notices_list = Hash.new
    notices.each do |n|
      key = n.created_at.strftime("%d %B %Y")
      if notices_list[key]
        notices_list[key] << n
      else
        notices_list[key] = [n]
      end
    end
    notices_list
  end

  def show
  end

end
