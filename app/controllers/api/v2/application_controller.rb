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
        property_content_preview = tag_to_content_preview(tag)
      else
        featured_content_previews = get_content_previews(featured_tag_name)
      end
      
      params = request.params
      params["page_elements"] = nil
      params["comments_limit"] = 10
      calltoaction_info_list, has_more = get_ctas_for_stream(tag_name, params, cta_chunk_size)
      ctas_highlighted = map_highlighted_ctas_to_content_preview(get_cta_highlighted_carousel())
      result = {
        'call_to_action_info_list' => adjust_ctas_descriptions(calltoaction_info_list),
        'call_to_action_highlight_list' => ctas_highlighted,
        'call_to_action_info_list_version' => get_max_updated_at_from_cta_info_list(calltoaction_info_list),
        'call_to_action_info_list_has_more' => has_more,
        #'menu_items' => get_menu_items(),
        'featured_content_previews' => featured_content_previews.contents,
        # TODO: content section need to have their timestamp
        'content_sections' => [],
        'property' => property_content_preview
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
      
      if params[:calltoaction_id]
        params["other_params"]["gallery"]["calltoaction_id"] = params[:calltoaction_id]
        gallery_tag = get_tag_with_tag_about_call_to_action(CallToAction.find(params[:calltoaction_id]), "gallery").first

        is_ugc = Interaction.where(call_to_action_id: params[:calltoaction_id], resource_type: "Upload").where.not(when_show_interaction: "MAI_VISIBILE").count == 0
      end
      
      params["page_elements"] = nil
      calltoaction_info_list, has_more = get_ctas_for_stream(nil, params, $site.init_ctas)
      
      result = {
        'call_to_action_info_list' => calltoaction_info_list,
        'call_to_action_info_list_version' => get_max_updated_at_from_cta_info_list(calltoaction_info_list),
        'call_to_action_info_list_has_more' => has_more,
        'galleries' => get_api_gallery_ctas_carousel,
        'gallery_ctas_count' => get_gallery_ctas_count(),
        'gallery_tag' => gallery_tag,
        'is_ugc' => is_ugc

      }
      
      respond_with result.to_json
    end
    
    def index_catalogue
      #property = get_property_for_reward_catalogue
      all_rewards_hash = get_all_rewards_map(get_property_for_reward_catalogue)
      reward_stripes = []
      extra_info = {}
      if current_user
        user_rewards = get_user_rewards(all_rewards_hash).slice(0,8)
        reward_stripes << prepare_reward_section(user_rewards, "I miei premi", "gained", "fa fa-bullseye")
        user_available_rewards = get_user_available_rewards(all_rewards_hash)
        reward_stripes << prepare_reward_section(user_available_rewards, "Premi che puoi sbloccare", "avaiable", "fa fa-unlock-alt")
        header_message = "Hai #{get_counter_about_user_reward("credit")} crediti a disposizione"
        extra_info = {
          "credits" => get_counter_about_user_reward("credit")
        }
      else
        user_rewards = []
        user_available_rewards = []
        header_message = "Registrati per ottenere crediti e sbloccare i contenuti esclusivi della community."
      end

      reward_stripes << prepare_reward_section(all_rewards_hash.values, "Tutti i premi", "all", "fa fa-th-large")
      
      response = {
        "browse_sections" => reward_stripes,
        "query" => (header_message rescue nil),
        "extra_info" => extra_info
      }
      
      respond_with response.to_json
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