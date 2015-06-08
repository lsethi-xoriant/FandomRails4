 class Api::V2::ApplicationController < ApplicationController
    
    respond_to :json
    
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
      params["page_elements"] = ["like", "comment", "share"]
      calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, cta_chunk_size)
      ctas_highlighted = get_cta_highlighted_carousel()
  
      result = {
        'call_to_action_info_list' => calltoaction_info_list,
        'call_to_action_highlight_list' => ctas_highlighted,
        'call_to_action_info_list_version' => get_max_updated_at_from_cta_info_list(calltoaction_info_list),
        'call_to_action_info_list_has_more' => has_more,
        'menu_items' => get_menu_items(),
        'featured_content_previews' => featured_content_previews.contents,
        'properties' => init_property_info_list().contents,
        # TODO: content section need to have their timestamp
        'content_sections' => []
      }
      
      respond_with result.to_json
    end
    
    def load_more_ctas_in_stream
      cta_chunk_size = $site.init_ctas
      cta_chunk_size = 10
      
      tag = get_property()
      if tag
        tag_name = tag.name
      end

      params = request.params
      params["page_elements"] = ["like", "comment", "share"]
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
end