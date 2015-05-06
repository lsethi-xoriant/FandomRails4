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
    
    @browse_section = cache_long(get_browse_sections_cache_key(get_search_tags_for_tenant, extra_cache_key)) do 
      init_browse_sections(get_search_tags_for_tenant, @tag_browse) 
    end
    
    if params[:query]
      @query = params[:query]
    end
    
    @browse_section.each do |bs|
      bs.contents = compute_cta_status_contents(bs.contents)
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
    
    contents, total = get_contents_with_match(params[:query], 0, get_current_property)
    
    if total == 0
      handle_no_result(params[:query])
      return
    end
    
    @total = total
    contents = prepare_contents(contents)
    
    @contents = compute_cta_status_contents(contents)
    
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
    contents, total = get_contents_with_match(params[:query], offset, get_current_property)
    contents = prepare_contents(contents)
    
    contents = compute_cta_status_contents(contents)
    
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
    @category = Tag.includes(:tags_tags).find(params[:id])
    contents, @has_more = get_content_previews_with_tags([@category] + get_tags_for_category(@category), DEFAULT_VIEW_ALL_ELEMENTS)
    @tags = get_tags_from_contents(contents)
    @contents = compute_cta_status_contents(contents)
    
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
    [tag]
  end
  
  def index_category_load_more
    category = Tag.find(params[:tag_id])
    params[:limit] = {
      offset: params[:offset].to_i,
      perpage: DEFAULT_VIEW_ALL_ELEMENTS
    }
    contents, has_more = get_content_previews_with_tags([category] + get_tags_for_category(category), DEFAULT_VIEW_ALL_ELEMENTS, params)
    
    contents = compute_cta_status_contents(contents)
    
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
    
    @contents = compute_cta_status_contents(contents)
    
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
    contents = compute_cta_status_contents(contents)
    
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
      @contents = compute_cta_status_contents(contents)
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
  
  # Get an array of tags to use to filter contents. 
  # This is a hook is expected to be override by a multiproperty project   
  def get_search_tags_for_tenant
    []
  end
  
  #hook for filter search result in specific property if multiproperty site
  def get_current_property
    nil
  end
  
  # Old implementation of search that redirect to filtered browse page if no result
  # see browse helper docs for more information
  
  def full_search_old
    browse_settings = Setting.find_by_key(BROWSE_SETTINGS_KEY).value
    browse_areas = browse_settings.split(",")
    @browse_section = Array.new
    browse_areas.each do |area|
      if area.start_with?("$")
        func = "get_#{area[1..area.length]}"
        @browse_section << send(func, params[:query])
      else
        tag_area = Tag.find_by_name(area)
        if get_extra_fields!(tag_area).key? "contents"
          @browse_section << get_featured_with_match(tag_area, params[:query])
        else
          @browse_section << get_browse_area_by_category_with_match(tag_area, params[:query])
        end
      end
    end
  end
  
end
