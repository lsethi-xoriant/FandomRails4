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
    
    def index_stream
      browse_settings = get_browse_settings(nil)
      content_previews = []
      
      browse_settings.split(",").each do |section|
        if !section.start_with?("$")
          content_previews << tag_to_content_preview(Tag.find_by_name(section))
        end
      end
      
      response = {
        "content_previews" => content_previews
      }
      
      respond_with response.to_json
      
    end
    
    def browse_index
      category = Tag.includes(:tags_tags).references(:tags_tags).find(params[:id])
      
      params[:limit] = {
        offset: 0,
        perpage: DEFAULT_VIEW_ALL_ELEMENTS
      }
      content_preview_list = get_content_previews(category.name, get_tags_for_category(category), params, DEFAULT_VIEW_ALL_ELEMENTS)
      
      response = {
        "category" => category,
        "tags" => get_tags_from_contents(content_preview_list.contents),
        "contents" => content_preview_list.contents,
        "has_more" => content_preview_list.has_view_all
      }
      
      respond_with response.to_json
      
    end
    
    def browse_index_load_more
      category = Tag.find(params[:id])
      
      if params[:selected_tags]
        selected_tags = api_get_selected_tags(params[:selected_tags])
      else
        selected_tags = []
      end
      
      params[:limit] = {
        offset: params[:offset].to_i,
        perpage: DEFAULT_VIEW_ALL_ELEMENTS
      }
      content_preview_list = get_content_previews(category.name, get_index_category_load_more_tags(category, selected_tags), params, DEFAULT_VIEW_ALL_ELEMENTS)
      contents = content_preview_list.contents
      
      respond_with contents.to_json
    end
  
    # hook for tenant with multiproperty
    def get_tags_for_category(tag)
      property = get_property()
      if property.nil?
        [tag]
      else
        [tag, property]
      end
    end
  
end