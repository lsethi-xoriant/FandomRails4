module BrowseHelper
  
  # Get an array of tags to filter contents. 
  # Filter contents according to current property
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
          browse_sections_arr << send(func, 0, carousel_elements, tags)
        else
          browse_sections_arr << get_content_previews(area, tags)
        end
      end
    end
    browse_sections_arr
  end

  def get_recent(offset = 0, per_page = DEFAULT_BROWSE_ELEMENT_CAROUSEL, tags)
    params = {
      conditions:{
        without_user_cta: true
      },
      limit: {
        offset: offset,
        perpage: per_page
      }
    }
    
    recent = get_ctas_with_tags_in_and(tags.map{|t| t.id}, params)
    recent_contents = prepare_contents(recent)
    recent_contents = compute_cta_status_contents(recent_contents, current_or_anonymous_user)

    browse_section = ContentSection.new(
      {
        key: "recent",
        title: "I piu recenti",
        icon_url: get_browse_section_icon(nil),
        contents: recent_contents,
        view_all_link: build_viewall_link("/browse/view_recent"),
        column_number: DEFAULT_VIEW_ALL_ELEMENTS/4
      }
    )  
  end

  def get_recent_ctas_with_cache(tags, params = {})
    if tags.any?
      tag_names_for_cache = ""
      tags.each do |tag|
        tag_names_for_cache += "#{tag.name}_"
      end
      timestamp = from_updated_at_to_timestamp(get_last_updated_at(Tag, tags))
    else
      tag_names_for_cache = ""
      timestamp = from_updated_at_to_timestamp(get_last_updated_at(CallToAction))
    end

    ctas = cache_forever(get_recent_ctas_cache_key(tag_names_for_cache, timestamp, params)) do
      get_recent_ctas(tags, params)
    end
  end

  def get_last_updated_at(klass, instances = nil)
    if instances
      last_updated_at = klass.where(:id => instances.map{ |i| i.id }).maximum(:updated_at)
    else
      last_updated_at = klass.maximum(:updated_at)
    end
    last_updated_at
  end

  def get_recent_ctas(tags, params = {})
    params[:conditions] = {
      without_user_cta: true
    }
    
    get_ctas_with_tags_in_and(tags.map{|t| t.id}, params)
  end
  
  def build_viewall_link(url)
    unless $context_root.nil?
      url = "/#{$context_root}#{url}"
    end
    url
  end

  def compute_cta_status_contents(contents, user)
    cta_ids = []
    contents.each do |content|
      if content.type == "cta"
        cta_ids << content.id
      end
    end
    cta_statuses = {}
    unless cta_ids.empty?
      cta_statuses = cta_to_reward_statuses_by_user(user, CallToAction.includes(:interactions).where("call_to_actions.id in (?)", cta_ids).references(:interactions).to_a, 'point')
    end
    contents.each do |content|
      if content.type == "cta"
        content.status = cta_statuses[content.id.to_i]
      end
    end
    contents
  end
  
  def get_content_previews_by_tags(category, tags, carousel_elements, params = {})
    tags = [category] + tags
    unless params.key? :limit
      params[:limit] = {
        perpage: carousel_elements,
        offset: 0
      }
    end

    contents, has_more = get_content_previews_with_tags(tags, params)
    extra_fields = get_extra_fields!(category)

    browse_section = ContentSection.new({
      key: category.name,
      title:  category.title,
      extra_fields: category.extra_fields,
      icon_url: get_browse_section_icon(extra_fields),
      contents: contents,
      view_all_link: build_viewall_link("/browse/view_all/#{category.slug}"),
      column_number: DEFAULT_VIEW_ALL_ELEMENTS / get_section_column_number(extra_fields),
      has_view_all: has_more,
      per_page: carousel_elements,
      slug: category.slug
    })
  end
  
  def get_content_previews_by_tags_with_ordering(category, tags, carousel_elements, params = {})
    extra_fields = get_extra_fields!(category)
    contents = get_contents_from_ordering(category)
    
    if contents.count < carousel_elements
      unless params.key? :limit
        params[:limit] = {
          perpage: carousel_elements,
          offset: 0
        }
      end
      exclude_tag_ids = []
      exclude_cta_ids = []
      contents.each do |content|
        if content.type == "cta"
          exclude_cta_ids << content.id
        else
          exclude_tag_ids << content.id
        end
      end
      # params has class ActionController::Parameters, not Hash, so we need to be more verbose
      if exclude_tag_ids.any?
        if params[:conditions]
          params[:conditions][:exclude_tag_ids] = exclude_tag_ids
        else
          params[:conditions] = { :exclude_tag_ids => exclude_tag_ids }
        end
      end
      if exclude_cta_ids.any?
        if params[:conditions]
          params[:conditions][:exclude_cta_ids] = exclude_cta_ids
        else
          params[:conditions] = { :exclude_cta_ids => exclude_cta_ids }
        end
      end
      extra_contents, has_more = get_content_previews_with_tags([category] + tags, params)  
    end
    
    if extra_contents
      has_more = (contents.count + extra_contents.count) > carousel_elements
      contents = contents + extra_contents.slice(0, carousel_elements - contents.count)
    else
      has_more = contents.count > carousel_elements
    end

    browse_section = ContentSection.new({
      key: category.name,
      title:  category.title,
      extra_fields: category.extra_fields,
      icon_url: get_browse_section_icon(extra_fields),
      contents: contents,
      view_all_link: build_viewall_link("/browse/view_all/#{category.slug}"),
      column_number: DEFAULT_VIEW_ALL_ELEMENTS / get_section_column_number(extra_fields),
      has_view_all: has_more,
      per_page: carousel_elements,
      slug: category.slug
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
    icon_info = {}
    if !extra_fields.nil?
      if extra_fields["icon"] && upload_extra_field_present?(extra_fields["icon"])
        icon_info["html"] = "<img src='#{get_upload_extra_field_processor(extra_fields["icon"], :original)}' class='img-responsive' />"
        icon_info["html-class"] = ""
      elsif !extra_fields["icon"].nil?
        icon_info["html"] = "<span class=\"#{extra_fields["icon"]}\"></span>"
        icon_info["html-class"] = extra_fields["icon"]
      else
        icon_info["html"] = "<span class=\"fa fa-star\"></span>"
        icon_info["html-class"] = "fa fa-star"
      end
    else
      icon_info["html"] = "<span class=\"fa fa-star\"></span>"
      icon_info["html-class"] = "fa fa-star"
    end
    icon_info
  end
  
  def get_content_previews_with_tags(tags, params = {}) # TODO: removed carousel_elements
    begin
      perpage = params[:limit][:perpage]
      params[:limit][:perpage] = perpage + 1
    rescue Exception => exception
      throw Exception.new("perpage in content previews must be set")
    end

    tag_ids = tags.map { |tag| tag.id }
    tags = get_tags_with_tags(tag_ids, params)
    ctas = get_ctas_with_tags_in_and(tag_ids, params)

    contents_merged = merge_contents(ctas, tags, params)
    has_more = contents_merged.count > perpage
    contents_merged = contents_merged.slice(0, perpage)

    [contents_merged, has_more]
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
    optional_category_tag_ids_condition = category_tag_ids.any? ? "AND tag_id in (#{category_tag_ids.join(",")})" : ""
    if tags.empty?
      tags = Tag.where("title ILIKE ? AND id IN (?) ","%#{term}%", category_tag_ids).limit(DEFAULT_BROWSE_ELEMENT_CAROUSEL)
      ctas = get_ctas(nil).where("call_to_actions.title ILIKE ? AND call_to_actions.user_id is null", "%#{term}%").limit(DEFAULT_BROWSE_ELEMENT_CAROUSEL)
    else
      tag_set = tags.map { |tag| "(select tag_id from tags_tags where other_tag_id = #{tag.id} #{optional_category_tag_ids_condition})" }.join(' INTERSECT ')
      cta_set = tags.map { |tag| "(select call_to_action_id from call_to_action_tags where tag_id = #{tag.id})" }.join(' INTERSECT ')
      tags = Tag.where("title ILIKE ? AND id IN (#{tag_set})","%#{term}%").limit(DEFAULT_BROWSE_ELEMENT_CAROUSEL)
      ctas = get_ctas(nil).where("call_to_actions.title ILIKE ? AND call_to_actions.id in (#{cta_set}) AND call_to_actions.user_id is null", "%#{term}%").limit(DEFAULT_BROWSE_ELEMENT_CAROUSEL)
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
  
  # Convert a list of Call To Actions mixed with Tags into a list of ContentPreview.
  #   elements - list of Call To Actions mixed with Tags
  #   params   - used to handle a special case - see the get_cta_to_interactions_map() method documentation
  def prepare_contents(elements, params = {})
    contents = []
    
    cta_ids = []
    elements.each do |element|
      if element.class.name == "CallToAction"
        cta_ids << element.id 
      end
    end
    
    interactions = get_cta_to_interactions_map(cta_ids, params)
    elements.each do |element|
      if element.class.name == "CallToAction"
        element_interactions = get_interactions_from_cta_to_interaction_map(interactions, element.id)
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

  def merge_contents(ctas, tags, params = {})
    merged = (tags + ctas)
    prepare_contents(merged, params)
  end

  def merge_contents_for_autocomplete(ctas,tags)
    merged = (tags.sort_by(&:created_at).reverse + ctas.sort_by(&:created_at).reverse)
    prepare_contents_for_autocomplete(merged)
  end

  def merge_search_contents(ctas, tags)
    (tags.sort_by(&:created_at).reverse + ctas.sort_by(&:created_at).reverse)
  end

  def add_content_tags(tags, element)
    hidden_tags_ids = get_hidden_tag_ids
    element.tags.each do |k, t|
      if !tags.has_key?(t) && !hidden_tags_ids.include?(t)
        tags[t] = Tag.find(t)
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
  
  def get_contents_from_ordering(tag)
    ordering_names = get_extra_fields!(tag)['ordering']
    ctas = CallToAction.active.where("name IN (?) AND id IN (SELECT call_to_action_id FROM call_to_action_tags WHERE tag_id = #{tag.id})", ordering_names.split(",")).to_a
    tags = Tag.where("name IN (?) AND id IN (SELECT tag_id FROM tags_tags WHERE other_tag_id = #{tag.id})", ordering_names.split(","))
    contents = order_elements(tag, (tags + ctas))
    prepare_contents(contents)
  end

  def get_content_previews_excluding_ctas(main_tag_name, other_tags, excluding_cta_ids, number_of_elements)
    number_of_elements_with_excluding_ctas = number_of_elements + excluding_cta_ids.count
    content_previews = get_content_previews(main_tag_name, other_tags, {}, number_of_elements_with_excluding_ctas)
    content_previews_without_excluding_ctas_count = content_previews.contents.count
    content_previews.contents.delete_if { |obj| excluding_cta_ids.include?(obj.id) }

    unless content_previews.has_view_all
      if number_of_elements < content_previews.contents.count
        content_previews.has_view_all = true
      end
    end

    content_previews.contents[0..number_of_elements]
    content_previews
  end
  
  # This method is used to obtain a list of content previews starting from a tag name and a list of tags related to the context (i.e: current property or language)
  #   main_tag_name - the name of the tag that represents the content previews container
  #   other_tags    - list of context tag such as current property tag or language tag; these tags will be used to filter contents. It could be empty.
  #   params        - a dictionary containing further conditions to retrieve content from DB (see get_cta_where_clause_from_params for detail)
  def get_content_previews(main_tag_name, other_tags = [], params = {}, number_of_elements = nil)
    # Carousel elements if setted in content tag, if in section tag needs to be passed as function params
    main_tag = Tag.find_by_name(main_tag_name)
    # When a cta is edited the related tag is updated
    timestamp = from_updated_at_to_timestamp(main_tag.updated_at)

    main_tag_name_for_cache = main_tag_name
    if other_tags.any?
      other_tags.each do |tag|
        main_tag_name_for_cache = main_tag_name_for_cache + "_#{tag.name}"
      end
    end

    content_preview_list, carousel_elements = cache_forever(get_content_previews_cache_key(main_tag_name_for_cache, timestamp, params)) do
      # Params are used for cache key, so they shouldn't be modified. However some helpers could afterwards
      # modify the params, so they are cloned here.
      cloned_params = params.clone
      if number_of_elements.nil?
        carousel_elements = get_elements_for_browse_carousel(main_tag)
      else
        carousel_elements = number_of_elements
      end

      if(get_extra_fields!(main_tag)['ordering'] && !cloned_params[:related])
        content_preview_list = get_content_previews_by_tags_with_ordering(main_tag, other_tags, carousel_elements, cloned_params)
      else
        content_preview_list = get_content_previews_by_tags(main_tag, other_tags, carousel_elements, cloned_params)
      end

      content_preview_list.contents = compute_cta_status_contents(content_preview_list.contents, anonymous_user)
      [content_preview_list, carousel_elements]
    end

    if current_user
      timestamp = from_updated_at_to_timestamp(current_user.user_interactions.maximum(:updated_at))
      key = get_content_previews_statuses_for_tag_cache_key(main_tag_name_for_cache, current_user, timestamp, params)
      content_preview_list = cache_forever(key) do
        content_preview_list.contents = compute_cta_status_contents(content_preview_list.contents, current_user)
        content_preview_list
      end
    end

    interaction_id_to_resource_type = {}
    content_preview_list.contents.each do |content|
      if content.type == "cta" && content.interactions.present?
        content.interactions.each do |interaction| 
          interaction_id_to_resource_type[interaction[:interaction_info][:id]] = interaction[:interaction_info][:resource_type]
        end
      end
    end

    adjust_content_preview_counters(interaction_id_to_resource_type, content_preview_list)

    content_preview_list
  end

  def adjust_content_preview_counters(interaction_id_to_resource_type, content_preview_list)
    interaction_ids = interaction_id_to_resource_type.keys
    counters = ViewCounter.where("ref_type = 'interaction' AND ref_id IN (?)", interaction_ids)
    content_preview_list.contents.each do |content|
      if content.type == "cta" && content.interactions.present?
        content.interactions.each do |interaction|
          interaction_id = interaction[:interaction_info][:id]
          resource_type = interaction_id_to_resource_type[interaction_id].downcase
          if resource_type == "vote" || resource_type == "like" || resource_type == "comment"
            counter = find_interaction_in_counters(counters, interaction_id)
            counter = counter ? counter.counter : 0
            case resource_type
            when "vote"
              content.votes = counter
            when "like"
              content.likes = counter
            when "comment"
              content.comments = counter
            else
              # Nothing to do
            end
          end
        end
      end
    end
  end
  
  # WITH MATCH METHOD
  # these methods have been created for particular implementation of search: when the search string dose not match any contents 
  # the user will be redirected to brwose page with stripes filtered with contents similar to words on string search.
  # Every method below re-implement the above method of browse to implement this requirement no more in use in FANDOM
  
  def get_browse_area_by_category_with_match(category, query)
    contents = get_contents_by_category_with_match(category, query)
    extra_fields = get_extra_fields!(category)
    browse_section = ContentSection.new({
      key: category.name,
      title: category.title,
      icon_url: get_browse_section_icon(extra_fields),
      contents: contents,
      view_all_link: build_viewall_link("/browse/view_all/#{category.slug}"),
      column_number: DEFAULT_VIEW_ALL_ELEMENTS / get_section_column_number(extra_fields),
      slug: category.slug
    })
  end
  
  def get_contents_by_category_with_match(category, query)
    tags = get_tags_with_tag_with_match(category.name, query).sort_by { |tag| tag.created_at }
    ctas = get_ctas_with_tag_with_match(category.name, query).sort_by { |cta| cta.activated_at }
    merge_contents(ctas, tags)
  end
  
  def get_tags_from_contents(contents)
    tags = {}
    contents.each do |content|
      tags = add_content_tags(tags, content)
    end
    tags
  end
  
  def get_index_category_load_more_tags(tag, selected_tags)
    tags = get_tags_for_category(tag) + selected_tags
  end
  
  def get_selected_tags(selected_tags)
    Tag.where("id IN (?)", JSON.parse(selected_tags).map{ |k,v| k }).to_a
  end
  
  # duplicated method for ios api
  # in hangover don't know how to avoid duplication
  # TODO: find why IOS send an hash insted of a JSON
  def api_get_selected_tags(selected_tags)
    Tag.where("id IN (?)", selected_tags.map{ |k,v| k }).to_a
  end
  
end