class BrowseController < ApplicationController
  
  def index
    @tag_browse = get_tag_browse(params[:tagname])
    
    if @tag_browse
      @aux_other_params = { 
        page_tag: {
          "miniformat" => build_grafitag_for_tag(@tag_browse, "miniformat"),
          "header_image" => (get_upload_extra_field_processor(get_extra_fields!(@tag_browse)["header_image"])rescue nil)
        }
      }
      extra_cache_key = @tag_browse.name
      set_seo_info_for_tag(@tag_browse)
    else
      extra_cache_key = ""
    end
    
    @browse_section = init_browse_sections(get_search_tags_for_tenant(), @tag_browse) 
    
    if params[:query]
      @query = params[:query]
    end
    
  end

  # Get an array of tags to use to filter contents. 
  # Filter contents in base of current property
  def get_search_tags_for_tenant
    property = get_property()
    if property
      property.name == $site.default_property ? [] : [property]
    else
      []
    end
  end
  
  def get_tag_browse(tag_name)
    if tag_name.nil?
      nil
    else
      Tag.find_by_name(tag_name)
    end
  end
  
  # hook to redirect to browse in multitentant
  def go_to_browse
    redirect_to "/browse"
  end
  
  def get_not_found_message(query)
    "Non ci sono risultati per la tua ricerca '#{query}'."
  end
  
  def handle_no_result(query)
    flash[:notice] = get_not_found_message(query)
    go_to_browse
  end

  def full_search
    if params[:query].blank?
      handle_no_result("")
      return
    else
      @query = params[:query]
      log_info('full search', { query: @query })
    end

    property = get_property()
    if property
      property_name = property.name
    end

    contents, total = get_contents_with_match(params[:query], 0, property_name)

    if total == 0
      handle_no_result(params[:query])
      return
    end

    @total = total
    contents = prepare_contents(contents)

    @contents = compute_cta_status_contents(contents, current_or_anonymous_user)

    @aux_other_params = { 
      calltoaction_evidence_info: true,
      page_tag: {
        miniformat: {
          name: "search"
        }
      }
    }

    @query = params[:query]
    if @contents.empty?
      redirect_to "/browse"
    end

  end

  def full_search_load_more
    offset = params[:offset].to_i

    property = get_property()
    if property
      property_name = property.name
    end

    contents, total = get_contents_with_match(params[:query], offset, property_name)
    contents = prepare_contents(contents)
    
    contents = compute_cta_status_contents(contents, current_or_anonymous_user)
    
    respond_to do |format|
      format.json { render :json => contents.to_json }
    end
  end
  
  def get_tags_from_contents(contents)
    tags = {}
    contents.each do |content|
      tags = add_content_tags(tags, content)
    end
    tags
  end
  
  def index_category
    @category = Tag.includes(:tags_tags).references(:tags_tags).find(params[:id])
    params[:limit] = {
      offset: 0,
      perpage: DEFAULT_VIEW_ALL_ELEMENTS
    }
    content_preview_list = get_content_previews(@category.name, get_tags_for_category(@category), params, DEFAULT_VIEW_ALL_ELEMENTS)
    
    @tags = get_tags_from_contents(content_preview_list.contents)
    @contents = content_preview_list.contents
    @has_more = content_preview_list.has_view_all
    
    @aux_other_params = { 
      page_tag: {
        miniformat: {
          name: @category.name
        }
      }
    }
    
    set_seo_info_for_tag(@category)
    
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
  
  def index_category_load_more
    category = Tag.find(params[:tag_id])
    params[:limit] = {
      offset: params[:offset].to_i,
      perpage: DEFAULT_VIEW_ALL_ELEMENTS
    }
    content_preview_list = get_content_previews(category.name, get_tags_for_category(category), params, DEFAULT_VIEW_ALL_ELEMENTS)
    contents = content_preview_list.contents
    
    respond_to do |format|
      format.json { render :json => contents.to_json }
    end
  end
  
  def view_all
  end
  
  def view_all_recent
    params = {
      limit:{
        offset: 0,
        perpage: DEFAULT_VIEW_ALL_ELEMENTS + 1
      }
    }
    
    contents = get_recent_ctas(get_search_tags_for_tenant, params)
    @has_more = contents.count > DEFAULT_VIEW_ALL_ELEMENTS
    contents = prepare_contents(contents.slice(0, DEFAULT_VIEW_ALL_ELEMENTS))
    
    @contents = compute_cta_status_contents(contents, current_or_anonymous_user)
    
    @per_page = DEFAULT_VIEW_ALL_ELEMENTS
  end
  
  def view_all_recent_load_more
    parameters = {
      limit:{
        offset: params[:offset].to_i,
        perpage: DEFAULT_VIEW_ALL_ELEMENTS + 1
      }
    }
    contents = get_recent_ctas(get_search_tags_for_tenant, parameters)
    has_more = contents.count > DEFAULT_VIEW_ALL_ELEMENTS
    contents = prepare_contents(contents.slice(0, DEFAULT_VIEW_ALL_ELEMENTS))
    contents = compute_cta_status_contents(contents, current_or_anonymous_user)
    
    response = {
      contents: contents,
      has_more: has_more
    }
    
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end
  
  def search
    if flash[:notice]
      contents = get_recent_ctas(get_search_tags_for_tenant)
      contents = prepare_contents(contents.slice(0, 12))
      @contents = compute_cta_status_contents(contents, current_or_anonymous_user)
    end
    
    @aux_other_params = { 
      calltoaction_evidence_info: true,
      page_tag: {
        miniformat: {
          name: "search"
        }
      }
    }
    
  end
  
  def autocomplete_search
    term = params[:q]
    log_info("autocomplete", { query: term } )
    results = cache_short(get_browse_search_results_key(get_search_cache_key_params(term))) do 
      get_contents_by_query(term, get_search_tags_for_tenant).slice(0,8) 
    end
    respond_to do |format|
      format.json { render :json => results.to_a.to_json }
    end
  end
  
  def get_search_cache_key_params(term)
    term
  end
  
end
