#!/bin/env ruby
# encoding: utf-8

class GalleryController < ApplicationController
  def index
    @galleries_cta = get_gallery_ctas_carousel
    galleries_user_cta = get_gallery_ctas()
    @calltoaction_info_list = build_call_to_action_info_list(galleries_user_cta, ["like", "comment", "share"])
  end
  
  def show
    @galleries_cta = get_gallery_ctas_carousel
    cta = CallToAction.find(params[:id])
    @upload_interaction_id = cta.interactions.find_by_resource_type("Upload").id
    @aux_other_params = { "gallery" => build_call_to_action_info_list([cta]).first }
    @gallery_tag = get_tag_with_tag_about_call_to_action(cta, "gallery").first
    galleries_user_cta = get_gallery_ctas(@gallery_tag)
    @calltoaction_info_list = build_call_to_action_info_list(galleries_user_cta, ["like", "comment", "share"])
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
  
  def get_gallery_ctas_carousel
    gallery_tag_names = get_tags_with_tag("gallery").map{ |t| t.name}
    get_ctas_with_tags(gallery_tag_names)
  end
  
end
