#!/bin/env ruby
# encoding: utf-8

class GalleryController < ApplicationController

  def get_user_gallery_ctas(gallery = nil, user_id)
    if gallery.nil?
      gallery_tags = get_tags_with_tag("gallery")
      gallery_tags = order_elements("gallery", gallery_tags)
      gallery_tag_ids = gallery_tags.map{|t| t.id}
      if gallery_tag_ids.blank?
        []
      else
        user_ctas = CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id in (?) AND user_id = ?", gallery_tag_ids, user_id)
        user_ctas_with_limit = user_ctas.limit(6).to_a
        user_ctas_count = user_ctas.count
        [user_ctas_with_limit, user_ctas_count]
      end
    else
      user_ctas = CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ? AND call_to_actions.user_id = ?", gallery.id, user_id)
      user_ctas_with_limit = user_ctas.limit(6).to_a
      user_ctas_count = user_ctas.count
      [user_ctas_with_limit, user_ctas_count]
    end
  end

  def index

    @galleries_cta = get_gallery_ctas_carousel

    if params[:user]
      galleries_user_cta, galleries_user_cta_count = get_user_gallery_ctas(nil, params[:user])
    else
      galleries_user_cta, galleries_user_cta_count = cache_short(get_index_gallery_ctas_cache_key) { 
        [get_gallery_ctas(), get_gallery_ctas_count()] 
      }
    end

    @calltoaction_info_list = build_call_to_action_info_list(galleries_user_cta, ["like", "comment", "share", "vote"])
    @aux_other_params = { 
      "gallery" => true, 
      "gallery_index" => true,
      "gallery_calltoactions_count" => galleries_user_cta_count,
      "gallery_user" => params[:user]
    }

  end
  
  def take_current_gallery_to_first_position(gallery_slug, galleries)
    gallery_id = CallToAction.find(gallery_slug).id
    index = galleries.index{ |gal| gal[:cta].id == gallery_id.to_i}
    current_gallery = galleries[index]
    galleries.delete_at(index)
    galleries.unshift(current_gallery)
  end
  
  def get_ugc_number_gallery_map(tag_ids)
    cta_active_ids = CallToAction.active.pluck(:id)
    CallToActionTag.where("tag_id in (?) AND call_to_action_id in (?)", tag_ids, cta_active_ids).group(:tag_id).count
  end
  
  def show
    galleries_cta = get_gallery_ctas_carousel
    @galleries_cta = take_current_gallery_to_first_position(params[:id], galleries_cta)
    cta = CallToAction.find(params[:id])
    @cta_id = cta.id
    upload_interaction = cta.interactions.find_by_resource_type("Upload")
    @upload_interaction_id = upload_interaction.id
    @upload_active = upload_interaction.when_show_interaction != "MAI_VISIBILE"
    @gallery_tag = get_tag_with_tag_about_call_to_action(cta, "gallery").first

    if params[:user]
      galleries_user_cta, galleries_user_cta_count = get_user_gallery_ctas(@gallery_tag, params[:user])
    else
      galleries_user_cta, galleries_user_cta_count = cache_short(get_gallery_ctas_cache_key(@gallery_tag.id)) { 
        [get_gallery_ctas(@gallery_tag), get_gallery_ctas_count(@gallery_tag)]
      }
    end

    @calltoaction_info_list = build_call_to_action_info_list(galleries_user_cta, ["like", "comment", "share", "vote"])

    @aux_other_params = { 
      "gallery" => build_call_to_action_info_list([cta]).first,
      "gallery_show" => true,
      "gallery_calltoactions_count" => galleries_user_cta_count,
      "gallery_user" => params[:user]
    }
    
    if get_extra_fields!(cta)['form_extra_fields']
      @extra_fields = JSON.parse(get_extra_fields!(cta)['form_extra_fields'].squeeze(" "))['fields']
    else
      @extra_fields = nil
    end
    
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
      gallery_tags = get_tags_with_tag("gallery")
      gallery_tags = order_elements("gallery", gallery_tags)
      gallery_tag_ids = gallery_tags.map{|t| t.id}
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
      gallery_tag_ids = get_tags_with_tag("gallery").map{ |t| t.id}
      params = {
        conditions: { 
          without_user_cta: true 
        }
      }
      
      galleries = get_ctas_with_tags_in_or(gallery_tag_ids, params)
      construct_cta_gallery_info(galleries, gallery_tag_ids)
    end
  end
  
  def construct_cta_gallery_info(galleries, gallery_tag_ids)
    ugc_numebr_in_gallery_map = get_ugc_number_gallery_map(gallery_tag_ids)
    galleries_info = []
    galleries.each do |gallery|
      gallery_tag = get_tag_with_tag_about_call_to_action(gallery, "gallery").first
      galleries_info << {
        cta: gallery,
        count: ugc_numebr_in_gallery_map[gallery_tag.id]
      }
    end
    galleries_info
  end
  
  def how_to
    cta = CallToAction.find(params[:id])
    @cta_id = cta.id
    @gallery_tag = get_tag_with_tag_about_call_to_action(cta, "gallery").first
    @info = get_extra_fields!(@gallery_tag)
  end
  
end
