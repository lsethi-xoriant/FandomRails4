module BrowseHelper
  class BrowseCategory
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults

    # human readable name of this field
    attribute :title, type: String
    # html id of this field
    attribute :id, type: String
    attribute :type, type: String
    attribute :has_thumb, type: Boolean
    attribute :thumb_url, type: String
    attribute :description, type: String
    attribute :long_description, type: String
    attribute :detail_url, type: String
    attribute :created_at, type: Integer
    attribute :header_image_url, type: String
    attribute :icon, type: String
    attribute :category_icon, type: String
    attribute :status, type: String
    attribute :likes, type: Integer
    attribute :comments, type: Integer
    attribute :tags
  end
  
  def get_browse_settings
    cache_short(get_browse_settings_key) do
      Setting.find_by_key(BROWSE_SETTINGS_KEY)
    end
  end

  def init_browse_sections()
    browse_settings = get_browse_settings
    cache_medium(get_browse_sections_cache_key) do
      browse_sections_arr = []
      if browse_settings
        browse_areas = browse_settings.value.split(",")
        browse_areas.each do |area|
          if area.start_with?("$")
            func = "get_#{area[1..area.length]}"
            browse_sections_arr << send(func)
          else
            tag_area = Tag.find_by_name(area)
            if get_extra_fields!(tag_area).key? "contents"
              browse_sections_arr << get_featured(tag_area)
            else
              browse_sections_arr << get_browse_area_by_category(tag_area)
            end
          end
        end
      end
      browse_sections_arr
    end
  end

  def get_recent(offset = 0, per_page = 8, query = "")
    recent = get_recent_ctas(query).slice(offset, per_page)
    recent_contents = prepare_contents(recent)
    browse_section = ContentSection.new(
      key: "recent",
      title: "I piu recenti",
      icon_url: ActionController::Base.helpers.asset_path("icon-cat.png"),
      contents: recent_contents,
      view_all_link: "/browse/view_recent",
      column_number: 12/4
    )
  end

  def get_recent_ctas(query = "")
    cache_medium(get_recent_contents_cache_key(query)) do
      if query.empty?
        CallToAction.active.order("activated_at")
      else
        conditions = construct_conditions_from_query(query, "title")
        CallToAction.active.where("#{conditions}")
      end
    end
  end

  def get_featured(featured)
    featured_contents = get_featured_content(featured)
    browse_section = ContentSection.new(
      key: "featured",
      title: featured.title,
      icon_url: ActionController::Base.helpers.asset_path("icon-cat.png"),
      contents: featured_contents,
      view_all_link: "/browse/view_all/#{featured.id}",
      column_number: 12/4 #featured_contents.count
    )
  end
  
  def get_featured_with_match(featured, query)
    featured_contents = get_featured_content_with_match(featured, query)
    browse_section = ContentSection.new(
      key: "featured",
      title: featured.title,
      icon_url: ActionController::Base.helpers.asset_path("icon-cat.png"),
      contents: featured_contents,
      view_all_link: "/browse/view_all/#{featured.id}",
      column_number: 12/4 #featured_contents.count
    )
  end
  
  def get_browse_area_by_category(category)
    contents = get_contents_by_category(category)
    extra_fields = get_extra_fields!(category)
    browse_section = ContentSection.new(
      key: category.name,
      title:  extra_fields.fetch('title', category.name),
      icon_url: extra_fields["icon"] && upload_extra_field_present?(extra_fields["icon"]) ? get_upload_extra_field_processor(extra_fields["icon"], :original) : ActionController::Base.helpers.asset_path("icon-cat.png"),
      contents: contents,
      view_all_link: "/browse/view_all/#{category.id}",
      column_number: 12/4
    )
  end
  
  def get_browse_area_by_category_with_match(category, query)
    contents = get_contents_by_category_with_match(category, query)
    extra_fields = get_extra_fields!(category)
    browse_section = ContentSection.new(
      key: category.name,
      title: extra_fields.fetch('title', category.name),
      icon_url: (extra_fields["icon"] && upload_extra_field_present?(extra_fields["icon"])) ? get_upload_extra_field_processor(extra_fields["icon"], :original) : ActionController::Base.helpers.asset_path("icon-cat.png"),
      contents: contents,
      view_all_link: "/browse/view_all/#{category.id}",
      column_number: 12/4
    )
  end
  
  def get_contents_by_category(category)
    tags = get_tags_with_tag(category.name).slice(0,8).sort_by { |tag| tag.created_at }
    ctas = get_ctas_with_tag(category.name).slice(0,8).sort_by { |cta| cta.created_at }
    merge_contents(ctas, tags)
  end
  
  def get_contents_by_category_with_tags(category, offset = 0)
    tags = get_tags_with_tag(category.name).sort_by { |tag| tag.created_at }
    ctas = get_ctas_with_tag(category.name).sort_by { |cta| cta.created_at }
    merge_contents_with_tags(ctas, tags, offset)
  end
  
  def get_contents_by_category_with_match(category, query)
    tags = get_tags_with_tag_with_match(category.name, query).sort_by { |tag| tag.created_at }
    ctas = get_ctas_with_tag_with_match(category.name, query).sort_by { |cta| cta.created_at }
    merge_contents(ctas, tags)
  end
  
  def get_contents_with_match(query, offset = 0)
    property = get_disney_property
    contents, total = cache_medium(get_full_search_results_key(query, property)) do
      if property != "disney-channel"
        tags = get_tags_with_tag_with_match(property, query)
        ctas = get_ctas_with_tag_with_match(property, query).sort_by { |cta| cta.created_at }
      else
        tags = get_tags_with_match(query)
        ctas = get_ctas_with_match(query)
      end
      [merge_search_contents(ctas, tags), tags.count + ctas.count]
    end
    [contents.slice(offset, 12), total]
  end
  
  def get_contents_by_query(term)
    category_tag_ids = get_category_tag_ids()
    tags = Tag.where("title ILIKE ? AND id IN (?)","%#{term}%", category_tag_ids)
    ctas = CallToAction.active.where("title ILIKE ?","%#{term}%")
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

  def get_featured_content(featured)
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
    contents = prepare_contents(contents)
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
    elements.each do |element|
      if element.class.name == "CallToAction"
        contents << cta_to_category(element)
      else
        contents << tag_to_category(element)
      end
    end
    contents
  end
  
  def prepare_contents_for_autocomplete(elements)
    contents = []
    elements.each do |element|
      if element.class.name == "CallToAction"
        contents << cta_to_category_light(element, false)
      else
        contents << tag_to_category_light(element, false, false)
      end
    end
    contents
  end

  def merge_contents(ctas, tags, qty = 8, offset = 0)
    if qty > 0
      merged = (ctas + tags).sort_by(&:created_at).slice(offset, qty)
    else
      merged = (ctas + tags).sort_by(&:created_at)
    end
    prepare_contents(merged)
  end
  
  def merge_contents(ctas, tags, qty = 8, offset = 0)
    if qty > 0
      merged = (ctas + tags).sort_by(&:created_at).slice(offset, qty)
    else
      merged = (ctas + tags).sort_by(&:created_at)
    end
    prepare_contents(merged)
  end
  
  def merge_contents_for_autocomplete(ctas,tags)
    merged = (tags.sort_by(&:created_at) + ctas.sort_by(&:created_at))
    prepare_contents_for_autocomplete(merged)
  end
  
  def merge_contents_with_tags(ctas, tags, offset = 0)
    merged = (ctas + tags).sort_by(&:created_at).slice(offset, 12)
    prepare_contents_with_related_tags(merged)
  end
  
  def merge_search_contents(ctas, tags)
    (tags.sort_by(&:created_at) + ctas.sort_by(&:created_at))
  end
  
  def prepare_contents_with_related_tags(elements)
    contents = []
    tags = {}
    elements.each do |element|
      if element.class.name == "CallToAction"
        contents << cta_to_category(element)
        tags = addCtaTags(tags, element)
      else
        contents << tag_to_category(element, true)
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
      Tag.where("extra_fields->>'thumbnail' <> '' and extra_fields->>'header_image' <> ''").map{|t| t.id}
    end
  end

end