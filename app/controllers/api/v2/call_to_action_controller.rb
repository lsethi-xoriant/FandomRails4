 class Api::V2::CallToActionController < ApplicationController
    
    respond_to :json
    
    def get_related_ctas
      cta = CallToAction.find(params["cta_id"])
      related_content_previews, related_tag = init_related_ctas(cta, get_property())
      
      respond_with related_content_previews.to_json
    end
end