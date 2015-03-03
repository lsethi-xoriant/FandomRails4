module SeoHelper
  
  def set_seo_info(title, meta_description, keywords)
    @seo_info = {
      "title" => strip_tags(title),
      "meta_description" => strip_tags(meta_description),
      "keywords" => keywords
    }
  end

  def set_seo_info_for_cta(cta)
    set_seo_info(cta.title, cta.description, get_default_keywords())
  end

  def get_default_keywords
    Setting.find_by_keys("keywords").value rescue ""
  end

end