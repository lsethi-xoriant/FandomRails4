 class Api::V2::BrowseController < Api::V2::BaseController
    
    def get_stripe_from_tag
      stripe =  get_content_previews(params[:tag_name])
      respond_with stripe.to_json
    end

end