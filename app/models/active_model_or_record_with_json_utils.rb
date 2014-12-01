module ActiveModelOrRecordWithJSONUtils
    
  @json_attrs = []
  attr_accessor :json_attrs
  
  # Declares that this model contains some JSON attribute.
  #   attrs - a list of pairs; the first element of the pair is the JSON attribute name, the second is the attribute class.
  #
  # The attribute class can be an instance of JSONArray, that specifies the type of the contained elements.
  def json_attributes(attrs)
    @json_attrs = attrs
    @json_attrs.each do |json_attr_name, json_attr_class|
      if json_attr_class.instance_of? JSONArray
        validate_list_attr(json_attr_name, json_attr_class.elem_class)
      else
        validate_single_attr(json_attr_name, json_attr_class)
      end
    end
  end

  def validate_list_attr(json_attr_name, elem_class)
    result = true
    validates_each json_attr_name do |record, json_attr_name, list_value|
      list_value.each do |list_elem|
        value = elem_class.new(list_elem)
        result &= value.valid?
        handle_validation_errors(value.errors, record)
      end
    end
    result
  end

  def validate_single_attr(json_attr_name, json_attr_class)
    validates_each json_attr_name do |record, json_attr_name, value|
      value = {} if value.nil?
      if value.key? :$validating_model
        json_attr_class = value.delete(:$validating_model).constantize
      end
      
      value = json_attr_class.new(value)
 
      result = value.valid?
      handle_validation_errors(value.errors, record)
      result
    end
  end

  def handle_validation_errors(errors, record)
    errors.each do |attr_name, error|
      if attr == :base
        record.errors.add(attr_name, error)
      else
        record.errors.add("#{attr_name}", error)
      end
    end
  end
  
end
