module ViewHelper
  
  # Returns an input tag of the “text” type tailored for JSON fields.
  #   form    - the rails form
  #   path    - a specification of how to reach the field inside the JSON object. 
  #             For example 'aux/x/2/z' refers to a field z, in the third position of an array referred by 
  #             the field x of a field aux of the form object
  #   options - the text field options, as specified by rails' text_field method
  #
  # The implementation is quite obscure, as it is strongly coupled with rails' framework code
  def json_text_field(form, path, options)
    parts = path.split('/')
    options[:id] = "#{form.object_name}_#{parts.join('_')}"
    name = get_json_field_name(parts) 
    start_value = form.object.send(parts[0])

    if start_value.nil?
      start_value = {}
      form.object.send("#{parts[0]}=", start_value)
    end
    set_json_field_value(options, start_value, parts)
    form.text_field name, options
  end

  def get_json_field_name(path_parts)
    # handles the array indexes in path
    parts_without_indexes = path_parts.map { |x| digit?(x[0]) ? '' : x }
    "[#{parts_without_indexes.join('][')}]"
  end

  def set_json_field_value(options, start_value, parts)
    value = start_value
    parts[1..-1].each do |part|
      if value.nil?
        return
      end
      if digit? part[0] 
        part = part.to_i
      end
      value = value[part]
    end 
    options[:value] = value
  end
  
  def digit?(x)
    x =~ /[[:digit:]]/ 
  end


  # an efficient variant of link_to that support $context_root
  def light_link_to(url, options = nil, html_options = nil, &block)
    html_options, options = options, block if block_given?
    options ||= {}

    html_options = convert_options_to_data_attributes(options, html_options)
    
    unless $context_root.nil?
      url = "/#{$context_root}#{url}"
    end

    html_options['href'] ||= url

    content_tag(:a, url, html_options, &block)
  end
  
  # Returns the extra_fields field, converting it to hash if it has not been parsed.
  #
  #   element - any element supporting extra fields (CallToAction, Reward, Tag, ...)   
  #
  # Please note that this method sets extra_fields on the container by side-effect (hence the "bang" in the method name)
  def get_extra_fields!(element)
    begin
      if element.extra_fields.is_a? String
        element.extra_fields = JSON.parse(element.extra_fields)
        element.extra_fields
      else
        element.extra_fields || {}
      end
    rescue Exception => exception
      log_error("exception while trying to access 'extra_fields'", { backtrace: exception.backtrace, element: element.inspect })
      {}
    end
  end
  
  def upload_extra_field_present?(field)
    !field["attachment_id"].nil?
  end
  
  def get_upload_extra_field_processor(field, processor)
    parts = field["url"].split('/')
    parts[-2] = processor.to_s
    parts.join('/')
  end
  
end