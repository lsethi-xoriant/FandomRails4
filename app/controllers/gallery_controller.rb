#!/bin/env ruby
# encoding: utf-8

class GalleryController < ApplicationController
  def index

    @galleries_cta = get_gallery_ctas_carousel

    galleries_user_cta, galleries_user_cta_count = cache_short(get_index_gallery_ctas_cache_key) { 
      [get_gallery_ctas(), get_gallery_ctas_count()] 
    }

    @calltoaction_info_list = build_call_to_action_info_list(galleries_user_cta, ["like", "comment", "share"])
    @aux_other_params = { 
      "gallery" => true, 
      "gallery_calltoactions_count" => galleries_user_cta_count
    }

  end
  
  def show
    @galleries_cta = get_gallery_ctas_carousel
    cta = CallToAction.find(params[:id])
    @cta_id = cta.id
    upload_interaction = cta.interactions.find_by_resource_type("Upload")
    @upload_interaction_id = upload_interaction.id
    @upload_active = upload_interaction.when_show_interaction != "MAI_VISIBILE"
    @gallery_tag = get_tag_with_tag_about_call_to_action(cta, "gallery").first

    galleries_user_cta, galleries_user_cta_count = cache_short(get_gallery_ctas_cache_key(@gallery_tag.id)) { 
      [get_gallery_ctas(@gallery_tag), get_gallery_ctas_count(@gallery_tag)]
    }

    @calltoaction_info_list = build_call_to_action_info_list(galleries_user_cta, ["like", "comment", "share"])

    @aux_other_params = { 
      "gallery" => build_call_to_action_info_list([cta]).first,
      "gallery_calltoactions_count" => galleries_user_cta_count
    }
    @uploaded = false
    @error = false
    if !flash[:notice].blank?
      @uploaded = true
    elsif !flash[:error].blank?
      @error = true
    end
  end
  
  def get_gallery_ctas(gallery = nil)
    if gallery.nil?
      gallery_tag_ids = get_tags_with_tag("gallery").map{|t| t.id}
      if gallery_tag_ids.blank?
        []
      else
        CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id in (?) AND user_id IS NOT NULL", gallery_tag_ids).limit(6).to_a
      end
    else
      get_user_ctas_with_tag(gallery.name)
    end
  end

  def get_gallery_ctas_count(gallery = nil)
    if gallery.nil?
      gallery_tag_ids = get_tags_with_tag("gallery").map{|t| t.id}
      if gallery_tag_ids.blank?
        []
      else
        CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id in (?) AND user_id IS NOT NULL", gallery_tag_ids).count
      end
    else
      CallToAction.active_with_media.joins(:call_to_action_tags => :tag).where("tags.name = ? AND call_to_actions.user_id IS NOT NULL", gallery.name).count
    end
  end
  
  def get_gallery_ctas_carousel
    cache_medium(get_carousel_gallery_cache_key) do
      gallery_tag_names = get_tags_with_tag("gallery").map{ |t| t.name}
      get_ctas_with_tags(gallery_tag_names, true)
    end
  end
  
  def how_to
    cta = CallToAction.find(params[:id])
    @cta_id = cta.id
    @gallery_tag = get_tag_with_tag_about_call_to_action(cta, "gallery").first
    @info = get_extra_fields!(@gallery_tag)
  end
  
end
