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
  
  def index_category
    tag = Tag.find(params[:id])
    @category = tag.to_category
    tags = get_tags_with_tag(tag.name).order("tags.created_at DESC")
    ctas = get_ctas_with_tag(tag.name).order("call_to_actions.created_at DESC")
    @contents = merge_contents(ctas, tags)
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
  
  def get_recent
    recent = get_recent_ctas()
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
    contents = merge_contents(ctas, tags)
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
  
  def get_recent_ctas
    CallToAction.active.limit(6)
  end
  
  def view_all
    @tag = Tag.find(params[:id_cat])
    @contents = get_contents_by_category(@tag)
  end
  
  def merge_contents(ctas,tags)
    merged = (ctas + tags).sort_by(&:created_at)
    prepare_contents(merged)
  end
  
  def prepare_contents(elements)
    contents = []
    elements.each do |element|
      contents << element.to_category
    end
    contents
  end
  
  def search
    
  end
  
end
