class ActiveModelWithJSON
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModelOrRecordWithJSONUtils
  
end
