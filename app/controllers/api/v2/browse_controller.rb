 class Api::V2::BrowseController < ApplicationController
    #doorkeeper_for :all # Per autorizzare un contenuto
    #before_filter :check_application_client
    
    respond_to :json
    
    def get_stripe_from_tag
      stripe =  get_content_previews(params[:tag_name])
      respond_with stripe.to_json
    end

end