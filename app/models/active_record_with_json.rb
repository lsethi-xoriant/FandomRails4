class ActiveRecordWithJSON < ActiveRecord::Base
  self.abstract_class = true
  extend ActiveModelOrRecordWithJSONUtils

  # Same as the inherited methods, but it also add a before_save trigger to convert 
  # into json format the attributes passed as argument. This way each attribute can be initialized with an Hash, 
  # and validation can be performed by calling save(); if the validations pass, the conversion to json format
  # is handled automatically
  def self.json_attributes(attrs)
    before_save :handle_json
    super(attrs)
  end

  def handle_json
    self.class.json_attrs.each do |attr_name, attr_class|
      value = self.send(attr_name)
      if !(value.nil? || value.is_a?(String))
        self.send("#{attr_name}=", value.to_json)
      end
    end
  end
  
end
