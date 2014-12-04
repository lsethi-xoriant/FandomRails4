class ActiveModelWithJSON
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Serialization
  include ActiveModel::Conversion
  include ActiveModel::MassAssignmentSecurity
  extend ActiveModelOrRecordWithJSONUtils

  def initialize(attributes = nil)
    @attributes = attributes
  end

end

