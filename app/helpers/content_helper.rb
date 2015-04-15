module ContentHelper

  class ContentSection
    
    # key can be either tag name or special keyword such as $recent
    attr_accessor :key
    attr_accessor :title 
    attr_accessor :icon_url
    attr_accessor :contents
    attr_accessor :view_all_link
    attr_accessor :column_number
    attr_accessor :total
    attr_accessor :per_page
    attr_accessor :extra_fields
    attr_accessor :has_view_all
    
    def initialize(params)
      @key = params[:key]
      @title = params[:title]
      @icon_url = params[:icon_url]
      @contents = params[:contents]
      @view_all_link = params[:view_all_link]
      @column_number = params[:column_number]
      @total = params[:total]
      @per_page = params[:per_page]
      @extra_fields = params[:extra_fields]
      @has_view_all = params[:has_view_all]
    end
    
  end

  def get_content_preview_layout(content)
    get_extra_fields!(content)['layout'] || "default"
  end
  
  def build_content_preview_aux(obj)
    if obj.class.name == "CallToAction"
      {
        "miniformat" => build_grafitag_for_calltoaction(obj, "miniformat"),
        "flag" => build_grafitag_for_calltoaction(obj, "flag")
      }
    else
      {
        "miniformat" => build_grafitag_for_tag(obj, "miniformat"),
        "flag" => build_grafitag_for_tag(obj, "flag")
      }
    end
  end

  def tag_to_content_preview(tag, needs_related_tags = false, populate_desc = true)
    content_preview = tag_to_content_preview_light(tag, needs_related_tags, populate_desc)
    content_preview.aux = build_content_preview_aux(tag)
    content_preview
  end
  
  def tag_to_content_preview_light(tag, needs_related_tags = false, populate_desc = true)
    thumb_field = get_extra_fields!(tag)["thumbnail"]
    has_thumb = thumb_field && upload_extra_field_present?(thumb_field)
    thumb_url = get_upload_extra_field_processor(thumb_field,"medium") if has_thumb
    if get_extra_fields!(tag).key? "description"
      description = truncate(get_extra_fields!(tag)["description"], :length => 150, :separator => ' ')
      long_description = get_extra_fields!(tag)["description"]
    else
      description = ""
      long_description = ""
    end
    header_field = get_extra_fields!(tag)["header_image"]
    has_header = !header_field.blank? && upload_extra_field_present?(header_field)
    header_image = get_upload_extra_field_processor(header_field,"original") if has_header
    
    icon_field = get_extra_fields!(tag)["icon"]
    has_icon = !icon_field.blank? && upload_extra_field_present?(icon_field)
    icon = get_upload_extra_field_processor(icon_field,"medium") if has_icon
    
    category_icon_field = get_extra_fields!(tag)["category_icon"]
    has_category_icon_field = !category_icon_field.blank? && upload_extra_field_present?(category_icon_field)
    category_icon = get_upload_extra_field_processor(category_icon_field,"medium") if has_category_icon_field
    
    ContentPreview.new(
      type: "tag",
      id: tag.id,
      has_thumb: has_thumb, 
      thumb_url: thumb_url,
      title: tag.title,
      long_description: populate_desc ? long_description : nil,
      description: populate_desc ? description : nil,  
      detail_url: "/browse/category/#{tag.slug}",
      created_at: tag.created_at.to_i,
      header_image_url: header_image,
      icon: icon,
      category_icon: category_icon,
      tags: needs_related_tags ? get_tag_ids_for_tag(tag) : [],
      extra_fields: get_extra_fields!(tag),
      layout: get_content_preview_layout(tag),
      start: tag.valid_from,
      end: tag.valid_to
    )
  end
  
  def cta_to_content_preview(cta, populate_desc = true, interactions = nil)
    
    content_preview = cta_to_content_preview_light(cta, populate_desc)
    
    event_date_info = get_cta_event_start_end(interactions)
    
    content_preview.thumb_wide_url = (cta.thumbnail(:wide) rescue "") 
    content_preview.comments = get_number_of_comments_for_cta(cta)
    content_preview.likes = get_number_of_likes_for_cta(cta)
    content_preview.tags = get_tag_ids_for_cta(cta)
    content_preview.votes = get_votes_for_cta(cta.id)
    content_preview.aux = build_content_preview_aux(cta)
    content_preview.interactions = interactions
    content_preview.valid_from = cta.valid_from
    content_preview.valid_to = cta.valid_to
    content_preview.ical_id = event_date_info[:ical_id]
    content_preview
  end
  
  def cta_to_content_preview_light(cta, populate_desc = true)
    ContentPreview.new(
      type: "cta",
      media_type: cta.media_type,
      id: cta.id, 
      has_thumb: cta.thumbnail.present?, 
      thumb_url: cta.thumbnail(:thumb), 
      title: cta.title, 
      description: populate_desc ? truncate(cta.description, :length => 150, :separator => ' ') : nil,
      long_description: populate_desc ? cta.description : nil,
      detail_url: cta_url(cta),
      created_at: cta.created_at.to_time.to_i,
      comments: nil,
      likes: nil,
      status: nil,
      tags: nil,
      votes: nil,
      extra_fields: get_extra_fields!(cta),
      layout: get_content_preview_layout(cta),
      start: cta.valid_from,
      slug: cta.slug,
      end: cta.valid_to
    )
  end

end