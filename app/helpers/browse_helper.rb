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

  def init_browse_sections()
    browse_settings = Setting.find_by_key(BROWSE_SETTINGS_KEY)
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
    return browse_sections_arr
  end

  def get_recent(query = "")
    recent = get_recent_ctas(query)
    recent_contents = prepare_contents(recent)
    browse_section = ContentSection.new(
      key: "recent",
      title: "I piu recenti",
      contents: recent_contents,
      view_all_link: "/browse/view_recent",
      column_number: 12/4
    )
  end

  def get_recent_ctas(query = "")
    if query.empty?
      CallToAction.active.limit(6)
    else
      conditions = construct_conditions_from_query(query, "title")
      CallToAction.active.where("#{conditions}").limit(6)
    end
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

end