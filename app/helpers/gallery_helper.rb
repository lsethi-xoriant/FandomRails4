module GalleryHelper

  def adjust_params_for_gallery(params, gallery_calltoaction_id = "all")
    params = {} unless params

    params["other_params"] = {}
    params["other_params"]["gallery"] = {}
    params["other_params"]["gallery"]["calltoaction_id"] = gallery_calltoaction_id

    params["other_params"]["gallery"]["user"] = params[:user] if params[:user].present?

    params
  end
  
  def init_galleries_user_cta_count(gallery_calltoaction_id, property_name, user_id = nil)
    if user_id
      get_ctas(property_name, gallery_calltoaction_id).where("user_id = ?", user_id).count
    else
      get_ctas(property_name, gallery_calltoaction_id).count
    end
  end
  
  def get_gallery_ctas_count(user)
    gallery_calltoaction_id = "all"
    
    if $site.galleries_split_by_property
      property = get_property()
      property_name = property.name
      galleries_user_cta_count = init_galleries_user_cta_count(gallery_calltoaction_id, property, user)
    else
      property_name = nil
      galleries_user_cta_count = init_galleries_user_cta_count(gallery_calltoaction_id, nil, user)
    end
    
    galleries_user_cta_count 
  end

  def get_gallery_ctas_carousel
    get_gallery_ctas_carousel_aux("web") do |galleries, gallery_tag_ids|
      construct_cta_gallery_info(galleries, gallery_tag_ids)  
    end
  end  
  
  def get_gallery_ctas_carousel_aux(cache_prefix, &block)
    timestamp = Tag.select(:updated_at).find_by_name("gallery").updated_at
    if $site.galleries_split_by_property
      property = get_property()
      timestamp = [timestamp, property.updated_at].max 
    else
      property = nil
    end
    cache_key = get_carousel_gallery_cache_key(cache_prefix, from_updated_at_to_timestamp(timestamp), property.nil? ? nil : property.name)
    cache_forever(cache_key) do
      gallery_tag_ids = get_gallery_ctas_carousel_tag_ids(property)
      
      params = {
        conditions: { 
          without_user_cta: true 
        }
      }
      
      galleries = get_ctas_with_tags_in_or(gallery_tag_ids, params)
      yield galleries, gallery_tag_ids
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
  
  # This method is very similar to get_gallery_ctas_carousel, the only difference is the return value: here it's a list a content preview,
  # while in the other method is an ad-hoc list of Hashes geared around an ad-hoc carousel; in the future we should refactor all carousel
  # to be based on content previews, so the get_gallery_ctas_carousel method can be removed.
  # Of course a better solution would also be to use the get_content_previews() method instead of this; the only difference is that this method
  # filter by user_id and only gets ctas (not also tags)
  def get_api_gallery_ctas_carousel
    get_gallery_ctas_carousel_aux("api") do |galleries, gallery_tag_ids|
      gallery_carousel = []
      galleries.each do |gallery|
        gallery_carousel << cta_to_content_preview(gallery)
      end
    end
  end
  
end