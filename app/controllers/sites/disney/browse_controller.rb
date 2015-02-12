class Sites::Disney::BrowseController < BrowseController
  include DisneyHelper
  
  # hook to redirect to browse on the base of current property
  def go_to_browse
    redirect_to "#{get_disney_property_root_path}/browse"
  end
  
  def get_search_cache_key_params(term)
    "#{term}_#{get_disney_property}"
  end
  
  def get_search_tags_for_tenant
    if get_disney_property == "disney-channel" 
      []
    else
      [Tag.find_by_name(get_disney_property)]
    end
  end
  
  # hook for filter content with current property
  def get_tags_for_category(tag)
    if get_disney_property == "disney-channel" 
      [tag]
    else
      [tag, Tag.find_by_name(get_disney_property)]
    end
  end
  
end