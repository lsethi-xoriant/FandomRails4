module GalleryHelper

  def adjust_params_for_gallery(params, gallery_calltoaction_id = "all")
    params = {} unless params

    params["other_params"] = {}
    params["other_params"]["gallery"] = {}
    params["other_params"]["gallery"]["calltoaction_id"] = gallery_calltoaction_id

    params["other_params"]["gallery"]["user"] = params[:user] if params[:user].present?

    params
  end
  
  def get_gallery_ctas_count(gallery = nil)
    if gallery.nil?
      gallery_tag_ids = get_tags_with_tag("gallery").map{|t| t.id}
      if gallery_tag_ids.blank?
        []
      else
        CallToAction.active_with_media.includes(:call_to_action_tags).where("call_to_action_tags.tag_id in (?) AND user_id IS NOT NULL", gallery_tag_ids).references(:call_to_action_tags).count
      end
    else
      CallToAction.active_with_media.joins(call_to_action_tags: :tag).where("tags.name = ? AND call_to_actions.user_id IS NOT NULL", gallery.name).references(:call_to_action_tags, :tags).count
    end
  end
  
  def get_gallery_ctas_carousel
    if $site.galleries_split_by_property
      property = get_property()
    else
      property = nil
    end
    cache_medium(get_carousel_gallery_cache_key(property.nil? ? nil : property.name)) do
      gallery_tag_ids = get_gallery_ctas_carousel_tag_ids(property)
      
      params = {
        conditions: { 
          without_user_cta: true 
        }
      }
      
      galleries = get_ctas_with_tags_in_or(gallery_tag_ids, params)
      construct_cta_gallery_info(galleries, gallery_tag_ids)
    end
  end
  
  def get_gallery_ctas_carousel_tag_ids(property)
    if property
      tag_ids = Tag.select(:id).where(name: ["gallery", property.name]).map { |row| row.id }
      return get_tags_with_tags_in_and(tag_ids).map{ |t| t.id}
    else
      return get_tags_with_tag("gallery").map{ |t| t.id}
    end
  end

  def get_ugc_number_gallery_map(tag_ids)
    gallery_calltoaction_id = "all"
    cta_active_ids = get_ctas(nil, gallery_calltoaction_id).pluck(:id)
    CallToActionTag.where(tag_id: tag_ids, call_to_action_id: cta_active_ids).group(:tag_id).count
  end

  def construct_cta_gallery_info(galleries, gallery_tag_ids)
    ugc_number_in_gallery_map = get_ugc_number_gallery_map(gallery_tag_ids)
    galleries_info = []
    galleries.each do |gallery|
      gallery_tag = get_tag_with_tag_about_call_to_action(gallery, "gallery").first
      galleries_info << {
        cta: {
          name: gallery.name,
          id: gallery.id,
          thumbnail_medium: gallery.thumbnail(:medium),
          slug: gallery.slug,
          title: gallery.title
        },
        count: ugc_number_in_gallery_map[gallery_tag.id]
      }
    end
    galleries_info
  end
  
  # this function is almost a duplicate of get_gallery_ctas_carousel, i leave previous function for retrocompatibility
  # after refactoring of gallery page gallery carousel will return a list of content preview instead of a custom data structure
  def get_api_gallery_ctas_carousel
      gallery_tag_ids = get_tags_with_tag("gallery").map{ |t| t.id}
      params = {
        conditions: { 
          without_user_cta: true 
        }
      }
      galleries = get_ctas_with_tags_in_or(gallery_tag_ids, params)
      gallery_carousel = []
      galleries.each do |gallery|
        #gallery_tag = get_tag_with_tag_about_call_to_action(gallery, "gallery").first
        gallery_carousel << cta_to_content_preview(gallery)
      end
      
      gallery_carousel
  end
  
end