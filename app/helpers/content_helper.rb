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
    attr_accessor :slug
    
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
      @slug = params[:slug]
    end
    
  end
  
  class ContentPreview

    # human readable name of this field
    attr_accessor :title
    # html id of this field
    attr_accessor :id
    attr_accessor :name
    attr_accessor :type
    attr_accessor :media_type
    attr_accessor :has_thumb
    attr_accessor :thumb_url
    attr_accessor :thumb_wide_url
    attr_accessor :thumb_thumb_url
    attr_accessor :thumb_medium_url
    attr_accessor :thumb_hover_thumb_url
    attr_accessor :thumb_original_url
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
    attr_accessor :ical_id
    attr_accessor :interactions
    attr_accessor :valid_from
    attr_accessor :valid_to
    attr_accessor :slug
    #added to fit content preview also for reward objects
    attr_accessor :reward_info
    
    def initialize(params)
      @id = params[:id]
      @name = params[:name]
      @title = params[:title]
      @type = params[:type]
      @media_type = params[:media_type]
      @has_thumb = params[:has_thumb]
      @thumb_url = params[:thumb_url]
      @thumb_thumb_url = params[:thumb_thumb_url]
      @thumb_wide_url = params[:thumb_wide_url]
      @thumb_hover_thumb_url = params[:thumb_hover_thumb_url]
      @thumb_original_url = params[:thumb_original_url]
      @thumb_medium_url = params[:thumb_medium_url]
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
      @valid_from = params[:valid_from]
      @valid_to = params[:valid_to]
      @ical_id = params[:ical_id]
      @slug = params[:slug]
      @reward_info = params[:reward_info]
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
    if thumb_field.present? && upload_extra_field_present?(thumb_field)
      has_thumb = true
      thumb_medium_url = get_upload_extra_field_processor(thumb_field, "medium")
      thumb_thumb_url = get_upload_extra_field_processor(thumb_field, "thumb")
      thumb_original_url = get_upload_extra_field_processor(thumb_field, "original")
    else
      has_thumb = false
    end

    thumb_hover_field = get_extra_fields!(tag)["thumbnail_hover"]
    if thumb_hover_field.present? && upload_extra_field_present?(thumb_hover_field)
      thumb_hover_thumb_url = get_upload_extra_field_processor(thumb_hover_field, "thumb")
    end
    
    description = get_extra_fields!(tag)["description"]
    if description.present? && populate_desc
      description = truncate(description, :length => 150, :separator => ' ')
      long_description = description
    else
      description = ""
      long_description = ""
    end

    header_field = get_extra_fields!(tag)["header_image"]
    if header_field.present? && upload_extra_field_present?(header_field)
      header_image = get_upload_extra_field_processor(header_field, "original")
    end
    
    icon_field = get_extra_fields!(tag)["icon"]
    if icon_field.present? && upload_extra_field_present?(icon_field)
      icon = get_upload_extra_field_processor(icon_field, "medium")
    end
    
    category_icon_field = get_extra_fields!(tag)["category_icon"]
    if category_icon_field.present? && upload_extra_field_present?(category_icon_field)
      category_icon = get_upload_extra_field_processor(category_icon_field, "medium")
    end

    tags = needs_related_tags ? get_tag_ids_for_tag(tag) : []
    
    ContentPreview.new(
      type: "tag",
      id: tag.id,
      name: tag.name,
      slug: tag.slug,
      has_thumb: has_thumb, 
      thumb_thumb_url: thumb_thumb_url,
      thumb_hover_thumb_url: thumb_hover_thumb_url,
      thumb_url: thumb_medium_url,
      thumb_original_url: thumb_original_url,
      title: tag.title,
      long_description: long_description,
      description: description,  
      detail_url: "/browse/category/#{tag.slug}",
      created_at: tag.created_at.to_i,
      header_image_url: header_image,
      icon: icon,
      category_icon: category_icon,
      tags: tags,
      extra_fields: get_extra_fields!(tag),
      layout: get_content_preview_layout(tag),
      # keep these two fields without converting into int for compatibility with intesa calendar
      # don't know if they are used but to avoid regression i leave them [MATTEO]
      start: tag.valid_from,
      end: tag.valid_to
    )

  end
  
  def cta_to_content_preview(cta, populate_desc = true, interactions = nil)
    
    content_preview = cta_to_content_preview_light(cta, populate_desc)
    
    event_date_info = get_cta_event_start_end(interactions)
    
    content_preview.thumb_wide_url = (cta.thumbnail(:wide) rescue "") 
    content_preview.thumb_medium_url = (cta.thumbnail(:medium) rescue "") 
    # content_preview.comments = get_number_of_interaction_type_for_cta("Comment", cta)
    # content_preview.likes = get_number_of_interaction_type_for_cta("Like", cta)
    content_preview.tags = get_tag_ids_for_cta(cta)
    # content_preview.votes = get_number_of_interaction_type_for_cta("Vote", cta)
    content_preview.aux = build_content_preview_aux(cta)
    content_preview.interactions = interactions
    
    # ical_id, start and and are used to setup calendar widget and comes from ical interaction attached to cta
    content_preview.ical_id = event_date_info[:ical_id]
    content_preview.start = event_date_info[:start_date]
    content_preview.end = event_date_info[:end_date]
    
    content_preview
  end
  
  def cta_to_content_preview_light(cta, populate_desc = true)
    ContentPreview.new(
      type: "cta",
      media_type: cta.media_type,
      id: cta.id, 
      name: cta.name,
      has_thumb: cta.thumbnail.present?, 
      thumb_url: cta.thumbnail(:thumb), 
      title: cta.title, 
      description: populate_desc ? truncate(cta.description, :length => 150, :separator => ' ') : nil,
      long_description: populate_desc ? cta.description : nil,
      detail_url: cta_url(cta),
      created_at: cta.created_at.to_i,
      valid_from: cta.valid_from.nil? ? nil : cta.valid_from.to_i,
      valid_to: cta.valid_to.nil? ? nil : cta.valid_to.to_i,
      comments: nil,
      likes: nil,
      status: nil,
      tags: nil,
      votes: nil,
      extra_fields: get_extra_fields!(cta),
      layout: get_content_preview_layout(cta),
      slug: cta.slug,
    )
  end
    
  #reward-cta type 
  def reward_to_content_preview(reward, populate_desc = true)
    cta = reward.call_to_action
    ContentPreview.new(
      type: "reward-cta",
      media_type: nil,
      id: (cta.id rescue reward.id), 
      name: (cta.name rescue reward.name),
      has_thumb: true, 
      thumb_url: (cta.thumbnail(:thumb) rescue nil), 
      title: (cta.title rescue reward.title), 
      description: populate_desc ? truncate(cta.description, :length => 150, :separator => ' ') : nil,
      long_description: populate_desc ? cta.description : nil,
      detail_url: (cta_url(cta) rescue ""),
      created_at: (cta.created_at.to_i rescue nil),
      comments: nil,
      likes: nil,
      status: reward.cost,
      tags: nil,
      votes: nil,
      #extra_fields: get_extra_fields!(cta),
      #layout: get_content_preview_layout(cta),
      #slug: cta.slug,
      reward_info: {
        cost: reward.cost,
        currency: reward.currency_id,
        status: get_user_reward_status(reward),
        id: reward.id
      }
    )
  end


end