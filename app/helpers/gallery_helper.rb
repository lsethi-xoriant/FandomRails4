module GalleryHelper
  
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
    cache_medium(get_carousel_gallery_cache_key) do
      gallery_tag_ids = get_tags_with_tag("gallery").map{ |t| t.id}
      params = {
        conditions: { 
          without_user_cta: true 
        }
      }
      
      galleries = get_ctas_with_tags_in_or(gallery_tag_ids, params)
      construct_cta_gallery_info(galleries, gallery_tag_ids)
    end
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
        gallery_tag = get_tag_with_tag_about_call_to_action(gallery, "gallery").first
        gallery_carousel << tag_to_content_preview(gallery_tag)
      end
      
      gallery_carousel
  end
  
  
  def get_gallery_ctas_carousel
    cache_medium(get_carousel_gallery_cache_key) do
      gallery_tag_ids = get_tags_with_tag("gallery").map{ |t| t.id}
      params = {
        conditions: { 
          without_user_cta: true 
        }
      }
      
      galleries = get_ctas_with_tags_in_or(gallery_tag_ids, params)
      construct_cta_gallery_info(galleries, gallery_tag_ids)
    end
  end
  
end