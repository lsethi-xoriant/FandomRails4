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
        user_ctas = CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id in (?) AND user_id = ?", gallery_tag_ids, user_id).references(:call_to_action_tags)
        user_ctas_with_limit = user_ctas.limit(6).to_a
        user_ctas_count = user_ctas.count
        [user_ctas_with_limit, user_ctas_count]
      end
    else
      user_ctas = CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ? AND call_to_actions.user_id = ?", gallery.id, user_id).references(:call_to_action_tags)
      user_ctas_with_limit = user_ctas.limit(6).to_a
      user_ctas_count = user_ctas.count
      [user_ctas_with_limit, user_ctas_count]
    end
  end

  def init_galleries_user_cta_count(gallery_calltoaction_id, user_id = nil)
    if user_id
      get_ctas(nil, gallery_calltoaction_id).where("user_id = ?", user_id).count
    else
      get_ctas(nil, gallery_calltoaction_id).count
    end
  end

  def index
    @galleries_cta

    params = adjust_params_for_gallery(params)

    gallery_calltoaction_id = "all"
    galleries_user_cta_count = init_galleries_user_cta_count(gallery_calltoaction_id, params[:user])

    params["page_elements"] = ["like", "comment", "share"]
    @calltoaction_info_list, @has_more = get_ctas_for_stream(nil, params, $site.init_ctas)

    @aux_other_params = { 
      "gallery" => true, 
      "gallery_index" => true,
      "gallery_calltoactions_count" => galleries_user_cta_count,
      "gallery_user" => params[:user],
      "gallery_ctas" => get_gallery_ctas_carousel
    }

  end
  
  def take_current_gallery_to_first_position(gallery_slug, galleries)
    gallery_id = CallToAction.find(gallery_slug).id
    index = galleries.index{ |gal| gal[:cta][:id] == gallery_id.to_i}
    current_gallery = galleries[index]
    galleries.delete_at(index)
    galleries.unshift(current_gallery)
  end
  
  def get_ugc_number_gallery_map(tag_ids)
    gallery_calltoaction_id = "all"
    cta_active_ids = get_ctas(nil, gallery_calltoaction_id).pluck(:id)
    CallToActionTag.where(tag_id: tag_ids, call_to_action_id: cta_active_ids).group(:tag_id).count
  end
  
  def show
    galleries_cta = get_gallery_ctas_carousel
    @galleries_cta = take_current_gallery_to_first_position(params[:id], galleries_cta)
    cta = CallToAction.find(params[:id])
    @cta_id = cta.id
    upload_interaction = cta.interactions.find_by_resource_type("Upload")
    @upload_interaction_id = upload_interaction.id
    @upload_type = Interaction.find(@upload_interaction_id).aux["configuration"]["type"] rescue "flowplayer"
    @upload_active = upload_interaction.when_show_interaction != "MAI_VISIBILE"
    @gallery_tag = get_tag_with_tag_about_call_to_action(cta, "gallery").first

    gallery_calltoaction_id = cta.id

    params = adjust_params_for_gallery(params, gallery_calltoaction_id)

    galleries_user_cta_count = init_galleries_user_cta_count(gallery_calltoaction_id, params[:user])

    params["page_elements"] = ["like", "comment", "share"]
    gallery_tag_name = @gallery_tag.name
    @calltoaction_info_list, @has_more = get_ctas_for_stream(gallery_tag_name, params, $site.init_ctas)
          
    gallery_tag_adjust_for_view = build_gallery_tag_for_view(@gallery_tag, cta, upload_interaction)

    @aux_other_params = { 
      "upload_interaction_resource" => upload_interaction.resource,
      "gallery" => build_cta_info_list_and_cache_with_max_updated_at([cta]).first,
      "gallery_show" => true,
      "gallery_calltoactions_count" => galleries_user_cta_count,
      "gallery_user" => params[:user],
      gallery_tag: gallery_tag_adjust_for_view,
      "gallery_ctas" => get_gallery_ctas_carousel,
      "current_gallery_id" => cta.id
    }
  end

  def get_gallery_ctas(gallery = nil)
    if gallery.nil?
      gallery_tags = get_tags_with_tag("gallery")
      gallery_tags = order_elements("gallery", gallery_tags)
      gallery_tag_ids = gallery_tags.map{|t| t.id}
      if gallery_tag_ids.blank?
        []
      else
        CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id in (?) AND user_id IS NOT NULL", gallery_tag_ids).references(:call_to_action_tags).limit(6).to_a
      end
    else
      get_user_ctas_with_tag(gallery.name)
    end
  end
  
  def construct_cta_gallery_info(galleries, gallery_tag_ids)
    ugc_number_in_gallery_map = get_ugc_number_gallery_map(gallery_tag_ids)
    galleries_info = []
    galleries.each do |gallery|
      gallery_tag = get_tag_with_tag_about_call_to_action(gallery, "gallery").first
      galleries_info << {
        cta: {
          name: gallery.name,
          id: gallery.id,
          thumbnail_medium: gallery.thumbnail(:medium),
          slug: gallery.slug,
          title: gallery.title
        },
        count: ugc_number_in_gallery_map[gallery_tag.id]
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
