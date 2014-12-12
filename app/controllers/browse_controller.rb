class BrowseController < ApplicationController
  
  def index
    browse_settings = Setting.find_by_key(BROWSE_SETTINGS_KEY).value
    browse_areas = browse_settings.split(",")
    @browse_section = Array.new
    browse_areas.each do |area|
      if area.start_with?("$")
        func = "get_#{area[1..area.length]}"
        @browse_section << send(func)
      else
        tag_area = Tag.find_by_name(area)
        if tag_area.tag_fields.any? && tag_area.tag_fields.find_by_name("contents")
          @browse_section << get_featured(tag_area)
        else
          @browse_section << get_browse_area_by_category(tag_area)
        end
      end
    end
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
        if tag_area.tag_fields.any? && tag_area.tag_fields.find_by_name("contents")
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

  def get_featured(featured)
    featured_contents = get_featured_content(featured)
    browse_section = ContentSection.new(
      key: "featured",
      title: featured.tag_fields.find_by_name("title").value,
      contents: featured_contents,
      view_all_link: "/browse/view_all/#{featured.id}",
      column_number: 12/featured_contents.count
    )
  end
  
  def get_featured_with_match(featured, query)
    featured_contents = get_featured_content_with_match(featured, query)
    browse_section = ContentSection.new(
      key: "featured",
      title: featured.tag_fields.find_by_name("title").value,
      contents: featured_contents,
      view_all_link: "/browse/view_all/#{featured.id}",
      column_number: 12/featured_contents.count
    )
  end
  
  def get_featured_with_match(featured, query)
    featured_contents = get_featured_content(featured)
    browse_section = ContentSection.new(
      key: "featured",
      title: featured.tag_fields.find_by_name("title").value,
      contents: featured_contents,
      view_all_link: "/browse/view_all/#{featured.id}",
      column_number: 12/featured_contents.count
    )
  end
  
  def get_recent(query = "")
    recent = get_recent_ctas(query)
    recent_contents = prepare_contents(recent)
    browse_section = ContentSection.new(
      key: "recent",
      title: "I piu recenti",
      contents: recent_contents,
      view_all_link: "/browse/view_recent",
      column_number: 12/6
    )
  end
  
  def get_browse_area_by_category(category)
    contents = get_contents_by_category(category)
    browse_section = ContentSection.new(
      key: category.name,
      title: category.tag_fields.present? ? category.tag_fields.find_by_name("title").value : category.name,
      contents: contents,
      view_all_link: "/browse/view_all/#{category.id}",
      column_number: 12/6
    )
  end
  
  def get_contents_by_category(category)
    tags = get_tags_with_tag(category.name).sort_by { |tag| tag.created_at }
    ctas = get_ctas_with_tag(category.name).sort_by { |cta| cta.created_at }
    merge_contents(ctas, tags)
  end
  
  def get_contents_by_category_with_tags(category)
    tags = get_tags_with_tag(category.name).sort_by { |tag| tag.created_at }
    ctas = get_ctas_with_tag(category.name).sort_by { |cta| cta.created_at }
    merge_contents_with_tags(ctas, tags)
  end
  
  def get_browse_area_by_category_with_match(category, query)
    contents = get_contents_by_category_with_match(category, query)
    browse_section = ContentSection.new(
      key: category.name,
      title: category.tag_fields.present? ? category.tag_fields.find_by_name("title").value : category.name,
      contents: contents,
      view_all_link: "/browse/view_all/#{category.id}",
      column_number: 12/6
    )
  end
  
  def get_contents_by_category_with_match(category, query)
    tags = get_tags_with_tag_with_match(category.name, query).sort_by { |tag| tag.created_at }
    ctas = get_ctas_with_tag_with_match(category.name, query).sort_by { |cta| cta.created_at }
    merge_contents(ctas, tags)
  end
  
  def get_contents_by_query(term)
    browse_tag_ids = get_browse_tag_ids()
    tags = Tag.includes(:tags_tags).where("tags_tags.other_tag_id IN (?) OR tags.id IN (?)", browse_tag_ids, browse_tag_ids)
    tags = tags.where("name ILIKE ?","%#{term}%")
    #tags = Tag.where("name ILIKE ?","%#{term}%")
    ctas = CallToAction.where("title ILIKE ?","%#{term}%")
    merge_contents(ctas, tags)
  end
  
  def get_browse_tag_ids
    browse_settings = Setting.find_by_key(BROWSE_SETTINGS_KEY).value
    browse_areas = browse_settings.split(",")
    ids = []
    browse_areas.each do |area|
      if !area.start_with?("$")
        ids << Tag.find_by_name(area).id
      end
    end
    ids
  end

  def get_featured_content(featured)
    contents = Array.new
    featured.tag_fields.find_by_name("contents").value.split(",").each do |name|
      cta = CallToAction.find_by_name(name)
      if cta
        contents << cta
      else
        tag = Tag.find_by_name(name)
        contents << tag
      end
    end
    contents = prepare_contents(contents)
  end
  
  def get_featured_content_with_match(featured, query)
    contents = Array.new
    conditions = construct_conditions_from_query(query, "title")
    featured.tag_fields.find_by_name("contents").value.split(",").each do |name|
      cta = CallToAction.where("name = ? AND (#{conditions})", name)
      if cta
        contents << cta
      else
        tag = Tag.find_by_name(name)
        contents << tag
      end
    end
    contents = prepare_contents(contents)
  end
  
  def get_recent_ctas(query = "")
    if query.empty?
      CallToAction.active.limit(6)
    else
      conditions = construct_conditions_from_query(query, "title")
      CallToAction.active.where("#{conditions}").limit(6)
    end
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
  
  def prepare_contents(elements)
    contents = []
    elements.each do |element|
      if element.class.name == "CallToAction"
        contents << cta_to_category(element)
      else
        contents << tag_to_category(element)
      end
    end
    contents
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
        tags[t.tag.id] = t.tag.tag_fields.find_by_name("title").present? ? t.tag.tag_fields.find_by_name("title").value : t.tag.name
      end
    end
    tags
  end
  
  def addTagTags(tags, element)
    element.tags_tags.each do |t|
      other_tag = Tag.find(t.other_tag_id)
      if !tags.has_key?(other_tag.id)
        tags[t.other_tag_id] = other_tag.tag_fields.find_by_name("title").present? ? other_tag.tag_fields.find_by_name("title").value : other_tag.name
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
