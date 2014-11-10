#!/bin/env ruby
# encoding: utf-8

class GalleryController < ApplicationController
  def index
    @galleries_cta = calltoaction_active_with_tag("gallery", "DESC").where("user_id IS NULL")
    @galleries_user_cta = calltoaction_active_with_tag("gallery", "DESC").where("user_id IS NOT NULL")
    @calltoactions_during_video_interactions_second = init_calltoactions_during_video_interactions_second(@galleries_user_cta)
  end
  
  def show
    @calltoaction = CallToAction.find(params[:id])
    @upload_interaction = @calltoaction.interactions.find_by_resource_type("Upload")
    @gallery_tag = get_tag_with_tag_about_call_to_action(@calltoaction, "gallery").first
    @extra_info = cache_short(get_gallery_extra_info_key()) do
      extra = Hash.new
      TagField.where("tag_id = ?", @gallery_tag.id).each do |tf|
        if tf.field_type == "STRINGA"
          extra[tf.name] = tf.value
        else
          extra[tf.name] = tf.upload
        end
      end
      extra
    end
    
    @gallery_calltoactions = calltoaction_active_with_tag(@gallery_tag.name, "DESC").where("user_id IS NOT NULL AND approved = true")
  end
  
end
