class Easyadmin::EasyadminEventConsoleController < ApplicationController
  include EasyadminHelper
  include TableHelper

  layout "admin"
  
  # Constant that describe the filter available
  FIELD_DESCS = { 
    :date => FieldDesc.new({ :name => "Data", :id => "date", :model => "user_interaction", :column_name => "updated_at"}),
    :user => FieldDesc.new({ :name => "Utente", :id => "user", :model => "user", :column_name => "email"}),
    :interaction => FieldDesc.new({ :name => "Interazione", :id => "interaction", :model => "interaction", :column_name => "resource_type" })
  }
  
  # json version of fields description
  FIELD_DESCS_JSON = (FIELD_DESCS.map { |id, obj| [id, obj.attributes] }).to_json
  
  # Return the fields description Hash
  def get_fields
    FIELD_DESCS
  end
  
  # Called at first load initialize the filter interaction with the interaction type active
  def index
    @interaction_type_options = Interaction.uniq.pluck(:resource_type)
    @fields = FIELD_DESCS_JSON
  end
  
  # Give back the events query result depending on conditions passes as parameter
  #
  # offset - current page results to load
  # limit  - number of results per page
  def get_results(offset, limit)
    result = Hash.new
    if params[:conditions].blank?
      total = UserInteraction.count
      events = UserInteraction.limit(limit).offset(offset).order("updated_at ASC")
    else
      conditions = JSON.parse(params[:conditions])
      total = build_query(conditions).count
      events = build_query(conditions).limit(limit).offset(offset).order("user_interactions.updated_at ASC")
    end
    result['total'] = total
    result['elements'] = events
    return result
  end
  
  # construct the query to retrive events depending on filter params passed as parameter
  #
  # params - array of filter conidtions
  def build_query(params)
    query = UserInteraction.includes(:user).includes(:interaction).includes(:answer)
    fields = get_fields()
    params.each do |filter|
      field_id = filter['field'].to_sym
      operator = filter['operand']
      operand = filter['value']
      if operator == FILTER_OPERATOR_CONTAINS
        query = query.where( get_active_record_expression(fields[field_id]['column_name'], operator, fields[field_id]['model']), "%"+operand.to_s+"%" )
      else
        query = query.where( get_active_record_expression(fields[field_id]['column_name'], operator, fields[field_id]['model']), operand )
      end
    end
    return query  
  end
  
  # convert an element of the resultset into a hash easy to converto in json response
  #
  # e - resultset element
  def element_to_result(e)
    result = Hash.new
    result['date'] = e.updated_at.strftime("%d-%m-%Y %H:%M")
    result['user'] = e.user.email
    result['interaction'] = e.interaction.resource_type
    result
  end
  
end