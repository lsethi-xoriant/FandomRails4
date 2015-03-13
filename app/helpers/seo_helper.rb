module SeoHelper
  
  def set_seo_info(title, meta_description, keywords, meta_image)
    @seo_info = {
      "title" => strip_tags(title),
      "meta_description" => strip_tags(meta_description),
      "meta_image" => meta_image,
      "keywords" => keywords
    }
  end

  def set_seo_info_for_cta(cta)
    set_seo_info(cta.title, cta.description, get_default_keywords(), cta.thumbnail)
  end

  def get_default_keywords()
    Setting.find_by_key("keywords").value rescue ""
  end

end