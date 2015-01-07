class BrowseController < ApplicationController
  
  def index
    @browse_section = init_browse_sections()
  end
  
  def full_search
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
  
  def merge_contents(ctas,tags)
    merged = (ctas + tags).sort_by(&:created_at)
    prepare_contents(merged)
  end
  
  def merge_contents_with_tags(ctas,tags)
    merged = (ctas + tags).sort_by(&:created_at)
    prepare_contents_with_related_tags(merged)
  end
  
  def merge_search_contents(ctas, tags, offset, limit)
    merged = (ctas + tags).sort_by(&:created_at)
    prepare_contents(merged)
  end
  
  def prepare_contents_with_related_tags(elements)
    contents = []
    tags = {}
    elements.each do |element|
      if element.class.name == "CallToAction"
        contents << cta_to_category(element)
        tags = addCtaTags(tags, element)
      else
        contents << tag_to_category(element)
        tags = addTagTags(tags, element)
      end
    end
    [contents, tags]
  end
  
  def addCtaTags(tags, element)
    element.call_to_action_tags.includes(:tag).each do |t|
      if !tags.has_key?(t.tag.id)
        tags[t.tag.id] = get_extra_fields!(t.tag).fetch("title", t.tag.name)
      end
    end
    tags
  end
  
  def addTagTags(tags, element)
    element.tags_tags.each do |t|
      other_tag = Tag.find(t.other_tag_id)
      if !tags.has_key?(other_tag.id)
        tags[t.other_tag_id] = get_extra_fields!(other_tag).fetch("title", other_tag.name)
      end
    end
    tags
  end
  
  def search
    term = params[:q]
    results = cache_short(get_browse_search_results_key(term)) { get_contents_by_query(term) }
    respond_to do |format|
      format.json { render :json => results.to_a.to_json }
    end
  end
  
end
