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

  def index

    _params = adjust_params_for_gallery(params)

    if(_params[:user])
      user = User.find(_params[:user])
      user = {
        id: user.id,
        username: user.username
      }
    end
    
    if $site.galleries_split_by_property
      property = get_property()
      property_name = property.name
    else
      property_name = nil
    end
    
    galleries_user_cta_count = get_gallery_ctas_count(_params[:user])
    
    _params["page_elements"] = ["like", "comment", "share"]
    
    @calltoaction_info_list, @has_more = get_ctas_for_stream(property_name, _params, $site.init_ctas)

    @aux_other_params = { 
      "gallery_calltoaction" => true, 
      "gallery_index" => true,
      "gallery_calltoactions_count" => galleries_user_cta_count,
      "gallery_user" => user,
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
  
  def show
    galleries_cta = get_gallery_ctas_carousel
    @galleries_cta = take_current_gallery_to_first_position(params[:id], galleries_cta)
    cta = CallToAction.find(params[:id])
    @cta_id = cta.id
    upload_interaction = cta.interactions.find_by_resource_type("Upload")
    
    if upload_interaction
      @upload_interaction_id = upload_interaction.id
      @upload_type = Interaction.find(@upload_interaction_id).aux["configuration"]["type"] rescue "flowplayer"
      @upload_active = upload_interaction.when_show_interaction != "MAI_VISIBILE"
      resource = upload_interaction.resource
    end

    @gallery_tag = get_tag_with_tag_about_call_to_action(cta, "gallery").first

    gallery_calltoaction_id = cta.id

    _params = adjust_params_for_gallery(params, gallery_calltoaction_id)
    if(_params[:user])
      user = User.find(_params[:user])
      user = {
        id: user.id,
        username: user.username
      }
    end

    galleries_user_cta_count = init_galleries_user_cta_count(gallery_calltoaction_id, _params[:user])

    params["page_elements"] = ["like", "comment", "share"]
    gallery_tag_name = @gallery_tag.name
    @calltoaction_info_list, @has_more = get_ctas_for_stream(gallery_tag_name, _params, $site.init_ctas)
          
    gallery_tag_adjust_for_view = build_gallery_tag_for_view(@gallery_tag, cta, upload_interaction)

    @aux_other_params = { 
      "upload_interaction_resource" => resource,
      "gallery_calltoaction" => build_cta_info_list_and_cache_with_max_updated_at([cta]).first,
      "gallery_show" => true,
      "gallery_calltoactions_count" => galleries_user_cta_count,
      "gallery_user" => user,
      gallery_tag: gallery_tag_adjust_for_view,
      "gallery_ctas" => get_gallery_ctas_carousel
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
  
  def how_to
    cta = CallToAction.find(params[:id])
    @cta_id = cta.id
    @gallery_tag = get_tag_with_tag_about_call_to_action(cta, "gallery").first
    @info = get_extra_fields!(@gallery_tag)
  end
  
end
