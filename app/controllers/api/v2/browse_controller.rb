 class Api::V2::BrowseController < Api::V2::BaseController
    
    def get_stripe_from_tag
      stripe =  get_content_previews(params[:tag_name])
      respond_with stripe.to_json
    end
    
    def index
      
      browse_sections = init_browse_sections(get_search_tags_for_tenant(), nil) 
      
      if params[:query]
        query = params[:query]
      end
      
      response = {
        "browse_sections" => browse_sections,
        "query" => (query rescue nil)
      }
      
      respond_with response.to_json
      
    end
    
    def browse_index
      
    end

end