 class Api::V2::ApplicationController < Api::V2::BaseController   
    
    # possible (GET) params: 
    #   ordering = recent | view | comment
    def index
      cta_chunk_size = $site.init_ctas
      cta_chunk_size = 10
      
      tag = get_property()
      featured_tag_name = "featured"
      
      if tag
        tag_name = tag.name
        featured_content_previews = get_content_previews(featured_tag_name, [tag])
      else
        featured_content_previews = get_content_previews(featured_tag_name)
      end
      
      params = request.params
      params["page_elements"] = nil
      calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, cta_chunk_size)
      ctas_highlighted = map_highlighted_ctas_to_content_preview(get_cta_highlighted_carousel())
      result = {
        'call_to_action_info_list' => calltoaction_info_list,
        'call_to_action_highlight_list' => ctas_highlighted,
        'call_to_action_info_list_version' => get_max_updated_at_from_cta_info_list(calltoaction_info_list),
        'call_to_action_info_list_has_more' => has_more,
        'menu_items' => get_menu_items(),
        'featured_content_previews' => featured_content_previews.contents,
        # TODO: content section need to have their timestamp
        'content_sections' => []
      }
      
      respond_with result.to_json
    end
    
    def index_gallery
      params["other_params"] = {}
      params["other_params"]["gallery"] = {}
      params["other_params"]["gallery"]["calltoaction_id"] = "all"
  
      if params[:user]
        params["other_params"]["gallery"]["user"] = params[:user]
      end
      
      params["page_elements"] = nil
      calltoaction_info_list, has_more = get_ctas_for_stream(nil, params, $site.init_ctas)
      
      
      result = {
        'call_to_action_info_list' => calltoaction_info_list,
        'call_to_action_info_list_version' => get_max_updated_at_from_cta_info_list(calltoaction_info_list),
        'call_to_action_info_list_has_more' => has_more,
        'galleries' => get_api_gallery_ctas_carousel,
        'gallery_ctas_count' => get_gallery_ctas_count()
      }
      
      respond_with result.to_json
    end
    
    def get_properties
      result = { 'properties' => init_property_info_list().contents }
      respond_with_json result
    end

    def load_more_ctas_in_stream
      cta_chunk_size = $site.init_ctas
      cta_chunk_size = 10
      
      tag = get_property()
      if tag
        tag_name = tag.name
      end

      params = request.params
      params["page_elements"] = nil
      calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, cta_chunk_size)
      
      result = {
        'call_to_action_info_list' => calltoaction_info_list,
        'call_to_action_info_list_has_more' => has_more
      }
      
      respond_with result.to_json
    end

    def get_cta_highlighted_carousel()
      property = get_property()
      build_evidence_cta_info_list(property)
    end

    def get_max_updated_at_from_cta_info_list(calltoaction_info_list)
      result = nil
      calltoaction_info_list.each do |cta_info|
        updated_at = cta_info['calltoaction']['updated_at']
        if result.nil? || result < updated_at
          result = updated_at
        end
      end

      result.nil? ? "" : result
    end
    
    def map_highlighted_ctas_to_content_preview(hightlight_ctas)
      content_previews = []
      hightlight_ctas.each do |cta|
        content_previews << ContentPreview.new(
          type: "cta",
          id: cta["id"],
          thumb_url: cta["thumbnail_medium_url"], 
          title: cta["title"], 
          status: cta["status"],
          comments: cta["comment"],
          likes: cta["like"],
          tags: nil,
          votes: cta["vote"],
          slug: cta["slug"],
        )
      end
      content_previews
    end
end