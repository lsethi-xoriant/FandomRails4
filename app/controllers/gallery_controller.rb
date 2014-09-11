#!/bin/env ruby
# encoding: utf-8

class GalleryController < ApplicationController
  def index
    @galleries_cta = calltoaction_active_with_tag("Gallery", "DESC").where("user_id IS NULL")
    @galleries_user_cta = calltoaction_active_with_tag("Gallery", "DESC").where("user_id IS NOT NULL")
    @calltoactions_during_video_interactions_second = initCallToActionsDuringVideoInteractionsSecond(@galleries_user_cta)
  end
  
  def show
    @calltoaction = CallToAction.find(params[:id])
    @gallery_tag = get_tag_with_tag_about_call_to_action(@calltoaction, "Gallery").first
    @gallery_calltoactions = calltoaction_active_with_tag(@gallery_tag.name, "DESC").where("user_id IS NOT NULL AND approved = true")
  end
  
end
