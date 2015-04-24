Paperclip::Attachment.default_options[:s3_host_name] = 's3-eu-west-1.amazonaws.com'

# this is a nasty workaround to the paperclip marshal bug (if a paperclip field is accessed in a model instance,
# that instance cannot be marshalled anymore)
class ActiveRecord::Base
  def marshal_dump
    instance_values.except('_paperclip_attachments')
  end

  def marshal_load(data)
    data.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end
end
