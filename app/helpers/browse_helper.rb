module BrowseHelper
  
  class ContentPreview

    # human readable name of this field
    attr_accessor :title
    # html id of this field
    attr_accessor :id
    attr_accessor :type
    attr_accessor :media_type
    attr_accessor :has_thumb
    attr_accessor :thumb_url
    attr_accessor :description
    attr_accessor :long_description
    attr_accessor :detail_url
    attr_accessor :created_at
    attr_accessor :header_image_url
    attr_accessor :icon
    attr_accessor :category_icon
    attr_accessor :status
    attr_accessor :likes
    attr_accessor :comments
    attr_accessor :votes
    attr_accessor :tags
    attr_accessor :aux
    attr_accessor :extra_fields
    attr_accessor :layout
    attr_accessor :start
    attr_accessor :end
    attr_accessor :interactions
    
    def initialize(params)
      @id = params[:id]
      @title = params[:title]
      @type = params[:type]
      @media_type = params[:media_type]
      @has_thumb = params[:has_thumb]
      @thumb_url = params[:thumb_url]
      @description = params[:description]
      @long_description = params[:long_description]
      @detail_url = params[:detail_url]
      @created_at = params[:created_at]
      @header_image_url = params[:header_image_url]
      @icon = params[:icon]
      @category_icon = params[:category_icon]
      @status = params[:status]
      @likes = params[:likes]
      @comments = params[:comments]
      @votes = params[:votes]
      @tags = params[:tags]
      @aux = params[:aux]
      @extra_fields = params[:extra_fields]
      @layout = params[:layout]
      @start = params[:start]
      @end = params[:end]
      @interactions = params[:interactions]
    end
    
  end
  
  def get_browse_settings(tag_browse)
    if tag_browse
      extra_cache_key = tag_browse.name
    else
      extra_cache_key = ""
    end
    
    cache_short(get_browse_settings_key(extra_cache_key)) do
      if tag_browse
        get_extra_fields!(tag_browse)['browse_contents']
      elsif Setting.find_by_key(BROWSE_SETTINGS_KEY)
        Setting.find_by_key(BROWSE_SETTINGS_KEY).value
      else
        ""
      end
    end
  end

  def init_browse_sections(tags, tag_browse)
    browse_settings = get_browse_settings(tag_browse)
    browse_sections_arr = []
    carousel_elements = get_elements_for_browse_carousel(tag_browse)
    
    if browse_settings
      browse_areas = browse_settings.split(",")
      browse_areas.each do |area|
        if area.start_with?("$")
          func = "get_#{area[1..area.length]}"
          browse_sections_arr << send(func, 0, carousel_elements)
        else
          tag_area = Tag.find_by_name(area)
          if get_extra_fields!(tag_area).key? "contents"
            browse_sections_arr << get_featured(tag_area, carousel_elements)
          else
            browse_sections_arr << get_browse_area_by_category(tag_area, tags, carousel_elements)
          end
        end
      end
    end
    browse_sections_arr
  end

  def get_recent(offset = 0, per_page = DEFAULT_BROWSE_ELEMENT_CAROUSEL, query = "")
    recent = get_recent_ctas(query).slice(offset, per_page)
    recent_contents = prepare_contents(recent)
    browse_section = ContentSection.new(
    {
      key: "recent",
      title: "I piu recenti",
      icon_url: get_browse_section_icon(nil),
      contents: recent_contents,
      view_all_link: "/browse/view_recent",
      column_number: DEFAULT_VIEW_ALL_ELEMENTS/4
    }
    )
  end

  def get_recent_ctas(query = "")
    cache_medium(get_recent_contents_cache_key(query)) do
      ugc_tag = get_tag_from_params("ugc")
      
      if query.empty?
        calltoactions = CallToAction.active.order("activated_at DESC")
      else
        conditions = construct_conditions_from_query(query, "title")
        calltoactions = CallToAction.active.where("#{conditions}").order("activated_at DESC")
      end
      
      if ugc_tag
        ugc_calltoactions = CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", ugc_tag.id)
        if ugc_calltoactions.any?
          calltoactions = calltoactions.where("call_to_actions.id NOT IN (?)", ugc_calltoactions.map { |calltoaction| calltoaction.id })
        end
      end
      
      calltoactions.to_a
      
    end
  end
  
  def get_featured(featured, carousel_elements)
    featured_contents, total = get_featured_content(featured, carousel_elements)
    browse_section = ContentSection.new(
    {
      key: "featured",
      title: featured.title,
      icon_url: get_browse_section_icon(nil),
      contents: featured_contents,
      view_all_link: "/browse/view_all/#{featured.id}",
      column_number: DEFAULT_VIEW_ALL_ELEMENTS/4,
      total: total
    })
  end
  
  def get_featured_with_match(featured, query)
    featured_contents = get_featured_content_with_match(featured, query)
    browse_section = ContentSection.new({
      key: "featured",
      title: featured.title,
      icon_url: get_browse_section_icon(nil),
      contents: featured_contents,
      view_all_link: "/browse/view_all/#{featured.id}",
      column_number: DEFAULT_VIEW_ALL_ELEMENTS/4 #featured_contents.count
    })
  end
  
  def get_browse_area_by_category(category, tags, carousel_elements, params = {})
    contents, total = get_contents_by_category(category, tags, carousel_elements, params)
    extra_fields = get_extra_fields!(category)

    browse_section = ContentSection.new({
      key: category.name,
      title:  category.title,
      extra_fields: category.extra_fields,
      icon_url: get_browse_section_icon(extra_fields),
      contents: contents,
      view_all_link: "/browse/view_all/#{category.slug}",
      column_number: DEFAULT_VIEW_ALL_ELEMENTS / get_section_column_number(extra_fields),
      total: total,
      per_page: carousel_elements
    })
  end
  
  def get_section_column_number(extra_fields)
    if extra_fields['column_number'].nil?
      4
    else
      extra_fields['column_number'].to_i
    end
  end
  
  def get_browse_section_icon(extra_fields)
    if !extra_fields.nil?
      if extra_fields["icon"] && upload_extra_field_present?(extra_fields["icon"])
        "<img src='#{get_upload_extra_field_processor(extra_fields["icon"], :original)}' class='img-responsive' />"
      elsif !extra_fields["icon"].nil?
        "<span class=\"#{extra_fields["icon"]}\"></span>"
      else
        "<span class=\"fa fa-star\"></span>"
      end
    else
      "<span class=\"fa fa-star\"></span>"
    end      
  end
  
  def get_browse_area_by_category_with_match(category, query)
    contents = get_contents_by_category_with_match(category, query)
    extra_fields = get_extra_fields!(category)
    browse_section = ContentSection.new({
      key: category.name,
      title: category.title,
      icon_url: get_browse_section_icon(extra_fields),
      contents: contents,
      view_all_link: "/browse/view_all/#{category.slug}",
      column_number: DEFAULT_VIEW_ALL_ELEMENTS / get_section_column_number(extra_fields)
    })
  end
  
  def get_contents_by_category(category, tags, carousel_elements, params = {})
    params['limit'] = {
      offset: 0,
      perpage: carousel_elements
    }
    tag_ids = ([category] + tags).map{|tag| tag.id}
    tags = order_elements(category, get_tags_with_tags(tag_ids, params))
    ctas = order_elements(category, get_ctas_with_tags_in_and(tag_ids, params))

    total = tags.count + ctas.count
    tags = tags.slice!(0, carousel_elements)
    ctas = ctas.slice!(0, carousel_elements)
    [merge_contents(ctas, tags, ), ctas, tags, total]
  end
  
  def get_contents_by_category_with_tags(filter_tags, category, offset = 0)
    params = {
      limit: {
        offset: offset,
        perpage: DEFAULT_VIEW_ALL_ELEMENTS
      }
    }
    tags = order_elements(category, get_tags_with_tags(filter_tags.map{|t| t.id}, params))
    ctas = order_elements(category, get_ctas_with_tags_in_and(filter_tags.map{|t| t.id}, params))
    merge_contents_with_tags(ctas, tags, offset)
  end
  
  def get_contents_by_category_with_match(category, query)
    tags = get_tags_with_tag_with_match(category.name, query).sort_by { |tag| tag.created_at }
    ctas = get_ctas_with_tag_with_match(category.name, query).sort_by { |cta| cta.activated_at }
    merge_contents(ctas, tags)
  end
  
  def get_contents_with_match(query, offset = 0, property)
    contents, total = cache_medium(get_full_search_results_key(query, property)) do
      unless property.nil?
        tags = get_tags_with_tag_with_match(property, query)
        ctas = get_ctas_with_tag_with_match(property, query).sort_by { |cta| cta.activated_at }
      else
        tags = get_tags_with_match(query)
        ctas = get_ctas_with_match(query)
      end
      [merge_search_contents(ctas, tags), tags.count + ctas.count]
    end
    [contents.slice(offset, DEFAULT_VIEW_ALL_ELEMENTS), total]
  end
  
  def get_contents_by_query(term, tags)
    category_tag_ids = get_category_tag_ids()
    if tags.empty?
      tags = Tag.where("title ILIKE ? AND id IN (?) ","%#{term}%", category_tag_ids).limit(DEFAULT_BROWSE_ELEMENT_CAROUSEL)
      ctas = CallToAction.active.where("title ILIKE ? AND user_id is null","%#{term}%").limit(DEFAULT_BROWSE_ELEMENT_CAROUSEL)
    else
      tag_set = tags.map { |tag| "(select tag_id from tags_tags where other_tag_id = #{tag.id} AND tag_id in (#{category_tag_ids.join(",")}) )" }.join(' INTERSECT ')
      cta_set = tags.map { |tag| "(select call_to_action_id from call_to_action_tags where tag_id = #{tag.id} AND tag_id in (#{category_tag_ids.join(",")}) )" }.join(' INTERSECT ')
      tags = Tag.where("title ILIKE ? AND id IN (#{tag_set})","%#{term}%").limit(DEFAULT_BROWSE_ELEMENT_CAROUSEL)
      ctas = CallToAction.active.where("title ILIKE ? AND id in (#{cta_set}) AND user_id is null","%#{term}%").limit(DEFAULT_BROWSE_ELEMENT_CAROUSEL)
    end
    merge_contents_for_autocomplete(ctas, tags)
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

  def get_featured_content(featured, carousel_elements)
    contents = Array.new
    get_extra_fields!(featured)["contents"].split(",").each do |name|
      cta = CallToAction.find_by_name(name)
      if cta
        contents << cta
      else
        tag = Tag.find_by_name(name)
        contents << tag
      end
    end
    total = contents.count
    contents = prepare_contents(contents.slice(0, carousel_elements))
    [contents, total]
  end
  
  def get_featured_content_with_match(featured, query)
    contents = Array.new
    conditions = construct_conditions_from_query(query, "title")
    get_extra_fields!(featured)["contents"].split(",").each do |name|
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

  def prepare_contents(elements)
    contents = []
    
    cta_ids = []
    elements.each do |element|
      if element.class.name == "CallToAction"
        cta_ids << element.id 
      end
    end
    
    interactions = get_cta_to_interactions_map(cta_ids)
    
    elements.each do |element|
      if element.class.name == "CallToAction"
        element_interactions = interactions[element.id] 
        contents << cta_to_content_preview(element, true, element_interactions)
      else
        contents << tag_to_content_preview(element)
      end
    end
    contents
  end
  
  def prepare_contents_for_autocomplete(elements)
    contents = []
    elements.each do |element|
      if element.class.name == "CallToAction"
        contents << cta_to_content_preview_light(element, false)
      else
        contents << tag_to_content_preview_light(element, false, false)
      end
    end
    contents
  end

  def merge_contents(ctas, tags)
    merged = (tags + ctas)
    prepare_contents(merged)
  end
  
  def merge_contents_for_autocomplete(ctas,tags)
    merged = (tags.sort_by(&:created_at).reverse + ctas.sort_by(&:created_at).reverse)
    prepare_contents_for_autocomplete(merged)
  end
  
  def merge_contents_with_tags(ctas, tags, offset = 0)
    total = ctas.count + tags.count
    merged = (total > offset || offset == 0) ? (tags + ctas).slice(offset, DEFAULT_VIEW_ALL_ELEMENTS) : []
    prepared_contents = prepare_contents_with_related_tags(merged)
    prepared_contents + [total]
  end
  
  def merge_search_contents(ctas, tags)
    (tags.sort_by(&:created_at).reverse + ctas.sort_by(&:created_at).reverse)
  end
  
  def prepare_contents_with_related_tags(elements)
    contents = []
    tags = {}
    
    cta_ids = []
    elements.each do |element|
      if element.class.name == "CallToAction"
        cta_ids << element.id 
      end
    end
    
    interactions = get_cta_to_interactions_map(cta_ids)
    
    elements.each do |element|
      if element.class.name == "CallToAction"
        element_interactions = interactions[element.id]
        contents << cta_to_content_preview(element, true, element_interactions)
        tags = addCtaTags(tags, element)
      else
        contents << tag_to_content_preview(element, true)
        tags = addTagTags(tags, element)
      end
    end
    [contents, tags]
  end
  
  def addCtaTags(tags, element)
    hidden_tags_ids = get_hidden_tag_ids
    element.call_to_action_tags.each do |t|
      if !tags.has_key?(t.tag.id) && !hidden_tags_ids.include?(t.tag.id)
        tags[t.tag.id] = get_extra_fields!(t.tag).fetch("title", t.tag.name)
      end
    end
    tags
  end
  
  def addTagTags(tags, element)
    element.tags_tags.each do |t|
      other_tag = Tag.find(t.other_tag_id)
      if !tags.has_key?(other_tag.id)
        tags[other_tag.id] = other_tag.title
      end
    end
    tags
  end
  
  def get_category_tag_ids
    cache_short("category_tag_ids") do
      hidden_tags_ids = get_hidden_tag_ids
      if hidden_tags_ids.any?
        Tag.where("extra_fields->>'thumbnail' <> '' and extra_fields->>'header_image' <> '' AND id not in (?)", hidden_tags_ids).map{|t| t.id}
      else
        Tag.where("extra_fields->>'thumbnail' <> '' and extra_fields->>'header_image' <> ''").map{|t| t.id}
      end
    end
  end
  
  def get_elements_for_browse_carousel(tag_browse)
    if tag_browse && get_extra_fields!(tag_browse)['carousel_elements']
      get_extra_fields!(tag_browse)['carousel_elements'].to_i
    else
      Setting.find_by_key(BROWSE_CAROUSEL_SETTING_KEY).value.to_i rescue DEFAULT_BROWSE_ELEMENT_CAROUSEL
    end
  end
  
  def get_content_preview_stripe(stripe_tag_name, params = {})
    #carousel elements if setted in content tag, if in section tag needs to be passed as function params
    stripe_tag = Tag.find_by_name(stripe_tag_name)
    carousel_elements = get_elements_for_browse_carousel(stripe_tag)
    get_browse_area_by_category(stripe_tag, [], carousel_elements, params)
  end
  
end