class BrowseController < ApplicationController
  include BrowseHelper
  
  def index
    @browse_section = cache_long(get_browse_sections_cache_key(get_search_tags_for_tenant)) do init_browse_sections(get_search_tags_for_tenant) end
    
    cta_ids = []
    @browse_section.each do |bs|
      bs.contents.each do |content|
        if content["type"] == "cta"
          cta_ids << content["id"]
        end
      end
    end

    cta_statuses = {}
    unless cta_ids.empty?
      cta_statuses = cta_to_reward_statuses_by_user(current_or_anonymous_user, CallToAction.includes(:interactions).where("id in (?)", cta_ids).to_a, 'point')
    end
    
    @browse_section.each do |bs|
      bs.contents.each do |content|
        if content["type"] == "cta"
          content["status"] = cta_statuses[content["id"].to_i]
        end
      end
    end
  end
  
  # hook to redirect to browse in multitentant
  def go_to_browse
    redirect_to "/browse"
  end
  
  def get_not_found_message
    "Non ci sono risultati per la tua ricerca."
  end
  
  def full_search
    if params[:query].blank?
      flash[:notice] = get_not_found_message()
      go_to_browse()
      return
    end
    contents, total = get_contents_with_match(params[:query])
    @total = total
    contents = prepare_contents(contents)
    
    if FULL_SEARCH_CTA_STATUS_ACTIVE
      cta_ids = []
      contents.each do |content|
        if content["type"] == "cta"
          cta_ids << content["id"]
        end
      end
      cta_statuses = {}
      unless cta_ids.empty?
        cta_statuses = cta_to_reward_statuses_by_user(current_or_anonymous_user, CallToAction.includes(:interactions).where("id in (?)", cta_ids).to_a, 'point')
      end
      contents.each do |content|
        if content["type"] == "cta"
          content["status"] = cta_statuses[content["id"].to_i]
        end
      end
      @contents = contents
    else
      @contens = contents
    end
    
    
    @query = params[:query]
    if @contents.empty?
      redirect_to "/browse"
    end
  end
  
  def full_search_load_more
    offset = params[:offset].to_i
    contents, total = get_contents_with_match(params[:query], offset)
    contents = prepare_contents(contents)
    
    if FULL_SEARCH_CTA_STATUS_ACTIVE
      cta_ids = []
      contents.each do |content|
        if content["type"] == "cta"
          cta_ids << content["id"]
        end
      end
      cta_statuses = {}
      unless cta_ids.empty?
        cta_statuses = cta_to_reward_statuses_by_user(current_or_anonymous_user, CallToAction.includes(:interactions).where("id in (?)", cta_ids).to_a, 'point')
      end
      contents.each do |content|
        if content["type"] == "cta"
          content["status"] = cta_statuses[content["id"].to_i]
        end
      end
      contents = contents
    else
      contens = contents
    end
    
    respond_to do |format|
      format.json { render :json => contents.to_json }
    end
  end
  
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
  
  def index_category
    tag = Tag.includes(:tags_tags).find(params[:id])
    @category = tag_to_category(tag)
    contents, @tags, @total = get_contents_by_category_with_tags(get_tags_for_category(tag))
    @contents = compute_gallery_contents(contents)
  end
  
  # hook for tenant with multiproperty
  def get_tags_for_category(tag)
    [tag]
  end
  
  def index_category_load_more
    offset = params[:offset].to_i
    category = Tag.find(params[:tag_id])
    contents, tags, total = get_contents_by_category_with_tags(get_tags_for_category(category), offset)
    
    contents = compute_gallery_contents(contents)
    
    respond_to do |format|
      format.json { render :json => contents.to_json }
    end
  end

  def compute_gallery_contents(contents)
    if INDEX_CATEGORY_CTA_STATUS_ACTIVE
      cta_ids = []
      contents.each do |content|
        if content["type"] == "cta"
          cta_ids << content["id"]
        end
      end
      cta_statuses = {}
      unless cta_ids.empty?
        cta_statuses = cta_to_reward_statuses_by_user(current_or_anonymous_user, CallToAction.includes(:interactions).where("id in (?)", cta_ids).to_a, 'point')
      end
      contents.each do |content|
        if content["type"] == "cta"
          content["status"] = cta_statuses[content["id"].to_i]
        end
      end
      contents
    else
      contents
    end
  end
  
  def view_all
    @tag = Tag.find(params[:id])
    @contents = get_contents_by_category(@tag)
  end
  
  def view_all_recent
    contents = get_recent_ctas()
    @total = contents.count
    contents = prepare_contents(contents.slice(0, 12))
    
    cta_ids = []
    contents.each do |content|
      if content["type"] == "cta"
        cta_ids << content["id"]
      end
    end
    cta_statuses = {}
    unless cta_ids.empty?
      cta_statuses = cta_to_reward_statuses_by_user(current_or_anonymous_user, CallToAction.includes(:interactions).where("id in (?)", cta_ids).to_a, 'point')
    end
    contents.each do |content|
      if content["type"] == "cta"
        content["status"] = cta_statuses[content["id"].to_i]
      end
    end
    @contents = contents
    
    @per_page = 12
  end
  
  def view_all_recent_load_more
    contents = get_recent_ctas()
    offset = params[:offset].to_i
    contents = prepare_contents(contents.slice(offset, 12))
    
    cta_ids = []
    contents.each do |content|
      if content["type"] == "cta"
        cta_ids << content["id"]
      end
    end
    cta_statuses = {}
    unless cta_ids.empty?
      cta_statuses = cta_to_reward_statuses_by_user(current_or_anonymous_user, CallToAction.includes(:interactions).where("id in (?)", cta_ids).to_a, 'point')
    end
    contents.each do |content|
      if content["type"] == "cta"
        content["status"] = cta_statuses[content["id"].to_i]
      end
    end
    
    respond_to do |format|
      format.json { render :json => contents.to_json }
    end
  end
  
  def search
    term = params[:q]
    results = cache_short(get_browse_search_results_key(get_search_cache_key_params(term))) { get_contents_by_query(term, get_search_tags_for_tenant).slice(0,8) }
    respond_to do |format|
      format.json { render :json => results.to_a.to_json }
    end
  end
  
  def get_search_cache_key_params(term)
    term
  end
  
  def get_search_tags_for_tenant
    []
  end
  
end
