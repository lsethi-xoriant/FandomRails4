module SeoHelper
  
  def set_seo_info(title, meta_description, keywords, meta_image)
    @seo_info = {
      "title" => CGI.unescapeHTML(strip_tags(title)),
      "meta_description" => CGI.unescapeHTML(strip_tags(meta_description)),
      "meta_image" => meta_image,
      "keywords" => keywords
    }
  end

  def set_seo_info_for_cta(cta)
    seo_title, seo_meta_description = seo_info_from_extra_fields(cta)
    thumbnail = (URI.join(request.url, cta.thumbnail.url) rescue nil)
    set_seo_info(seo_title, seo_meta_description, get_default_keywords(), thumbnail)
  end
  
  def set_seo_info_for_tag(tag)
    seo_title, seo_meta_description = seo_info_from_extra_fields(tag)
    
    extra_fields = get_extra_fields!(tag)
    thumbnail = get_upload_extra_field_processor(extra_fields['thumbnail'], :medium) rescue nil
    set_seo_info(seo_title, seo_meta_description, get_default_keywords(), thumbnail)
  end

  def seo_info_from_extra_fields(el)
    extra_fields = get_extra_fields!(el)
    seo_title = extra_fields["seo_title"] ? extra_fields["seo_title"] : el.title
    seo_meta_description = extra_fields["seo_meta_description"] ? extra_fields["seo_meta_description"] : el.description
    [seo_title, seo_meta_description]
  end

  def get_default_keywords()
    Setting.find_by_key("keywords").value rescue ""
  end

  def compute_seo(title_separator = "|")
    seo_values_to_set = ["title", "meta_description", "keywords", "meta_image"]

    property = get_property()
    if property
      property_extra_fields = get_extra_fields!(property)
    end

    seo_values_to_set.each do |value|
      compute_seo_value(value, title_separator, property_extra_fields)
    end 
  end

  def compute_seo_value(value, title_separator, property_extra_fields)
    if property_extra_fields
      seo_value_from_settings = property_extra_fields["seo_#{value}"]
    else
      seo_value_from_settings = get_seo_value_from_settings(value)
    end

    if @seo_info && @seo_info[value]
      seo_value = "#{@seo_info[value]}"
      if value == "title"
        seo_value = "#{seo_value} #{title_separator} #{seo_value_from_settings}"
      end
    else
      seo_value = seo_value_from_settings
    end
    instance_variable_set("@seo_#{value}", seo_value)
  end

  def update_seo_value(seo_value, seo_key, title_separator = "|")
    seo_value_from_settings = get_seo_value_from_settings(seo_key)
    if seo_key == "title"
      seo_value = "#{seo_value} #{title_separator} #{seo_value_from_settings}"
    end
    instance_variable_set("@seo_#{seo_key}", seo_value)
  end

  def get_seo_value_from_settings(value)
    Setting.find_by_key(value).value rescue ""
  end


end