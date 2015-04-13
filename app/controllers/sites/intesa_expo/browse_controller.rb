class Sites::IntesaExpo::BrowseController < BrowseController
  include IntesaExpoHelper
  # hook to redirect to browse on the base of current property
  def go_to_browse
    url = "/browse/full_search"
    unless $context_root.nil?
      url = "/#{$context_root}#{url}"
    end
    redirect_to url
  end
  
  def handle_no_result(query)
    flash[:notice] = get_not_found_message(query)
  end
  
  def tag_has_priority_tag(tag, tag_name)
    priority_tag = get_tag_from_params(tag_name)
    return tag.tags_tags.where("other_tag_id = ?", priority_tag.id).any?
  end

  def go_to_context(tag, context_name)
    assets = get_tag_from_params("assets")
    assets_extra_fields = JSON.parse(assets.extra_fields)
    redirect_to "#{assets_extra_fields[context_name]}/browse/category/#{tag.slug}"
  end
  
  def intesa_index_category
    # call index category of parent class to personalize intesa index category page with further information and
    # display settings
    index_category

    if get_intesa_property() == "imprese"
      if tag_has_priority_tag(@category, "it-priority") 
        go_to_context(@category, "expo_url")
      end
    elsif get_intesa_property() == "it"
      if tag_has_priority_tag(@category, "imprese-priority") 
        go_to_context(@category, "imprese_url")
      end
    end
    
    extra_fields = get_extra_fields!(@category)
    @aux_other_params = {
      "tag_menu_item" => extra_fields["menu_item"]
    }
    
    if extra_fields['top_stripe']
      @aux_other_params['top_stripe'] = get_content_preview_stripe(extra_fields['top_stripe']) 
    end
    
    if extra_fields['bottom_stripe']
      @aux_other_params['bottom_stripe'] = get_content_preview_stripe(extra_fields['bottom_stripe']) 
    end
    
    @use_filter = extra_fields['use_filter'].nil? ? false : extra_fields['use_filter']['value']
    
  end
  
end