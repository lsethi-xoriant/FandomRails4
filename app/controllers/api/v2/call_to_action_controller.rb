 class Api::V2::CallToActionController < Api::V2::BaseController    
    
    def get_related_ctas
      cta = CallToAction.find(params["cta_id"])
      related_content_previews, related_tag = init_related_ctas(cta, get_property())
      
      respond_with related_content_previews.to_json
    end
    
    def update_interaction
      send_anonymous_user = current_user.nil?
      begin
        result = update_interaction_computation(params)
  
        # update_interaction will create a new user if the user was not logged, it needs to be passed explicitly in the mobile API
        if send_anonymous_user
          result[:anonymous_user] = current_user
        end
      rescue Exception => e
        result = { "exception" => e.to_s }
      end

      respond_to do |format|
        format.json { render :json => result.to_json }
      end
    end
    
    def get_single_cta
      cta = CallToAction.find(params["cta_id"])
      cta_info = build_cta_info_list_and_cache_with_max_updated_at([cta]).first
      cta_info["calltoaction"]["description"] = HTMLEntities.new.decode(strip_tags(cta_info["calltoaction"]["description"]))
      respond_with cta_info.to_json
    end
    
    def redo_test
      cta_info = reset_redo_user_interactions
      respond_with cta_info.to_json
    end

    def upload
      upload_helper
    end
end