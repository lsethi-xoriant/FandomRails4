class BrowseController < ApplicationController
  
  def index
    @browse_section = init_browse_sections()
  end
  
  def full_search
    contents = get_contents_with_match(params[:query])
    @total = contents.count
    @contents = contents.slice(0,12)
    @query = params[:query]
    if @contents.empty?
      redirect_to "/browse"
    end
  end
  
  def full_search_load_more
    offset = params[:offset].to_i
    contents = get_contents_with_match(params[:query]).slice(offset,12)
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
    tag = Tag.find(params[:id])
    @category = tag_to_category(tag)
    @contents, @tags = get_contents_by_category_with_tags(tag)
  end
  
  def view_all
    @tag = Tag.find(params[:id])
    @contents = get_contents_by_category(@tag)
  end
  
  def search
    term = params[:q]
    results = cache_short(get_browse_search_results_key(term)) { get_contents_by_query(term) }
    respond_to do |format|
      format.json { render :json => results.to_a.to_json }
    end
  end
  
end
