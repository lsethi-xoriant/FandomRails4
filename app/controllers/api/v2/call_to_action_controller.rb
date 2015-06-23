 class Api::V2::CallToActionController < Api::V2::BaseController    
    
    def get_related_ctas
      cta = CallToAction.find(params["cta_id"])
      related_content_previews, related_tag = init_related_ctas(cta, get_property())
      
      respond_with related_content_previews.to_json
    end
    
    def update_interaction
      response = update_interaction_helper(params)
      respond_to do |format|
        format.json { render :json => response.to_json }
      end
    end
end