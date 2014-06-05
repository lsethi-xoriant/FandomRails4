
class Easyadmin::EasyadminEventConsoleController < ApplicationController
  include EasyadminHelper
  include TableHelper

  layout "admin"
    
  FIELD_DESCS = { 
    :date => FieldDesc.new({ :name => "Data", :id => "date", :model => "userinteraction", :column_name => "updated_at"}),
    :user => FieldDesc.new({ :name => "Utente", :id => "user", :model => "user", :column_name => "email"}),
    :interaction => FieldDesc.new({ :name => "Interazione", :id => "interaction", :model => "interaction", :column_name => "resource_type" })
  }
  
  FIELD_DESCS_JSON = (FIELD_DESCS.map { |id, obj| [id, obj.attributes] }).to_json
  
  def get_fields
    FIELD_DESCS
  end
  
  def index
    @interaction_type_options = Interaction.uniq.pluck(:resource_type)
    @fields = FIELD_DESCS_JSON
  end
  
  def get_results(offset, limit)
    if params[:conditions].blank?
      events = Userinteraction.limit(limit).offset(offset).order("updated_at ASC")
    else
      conditions = JSON.parse(params[:conditions])
      events = build_query(conditions).limit(limit).offset(offset).order("userinteractions.updated_at ASC")
    end
    return events
  end
  
  def build_query(params)
    query = Userinteraction.includes(:user).includes(:interaction).includes(:answer)
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

  def element_to_result(e)
    result = Hash.new
    result['date'] = e.updated_at.strftime("%d-%m-%Y %H:%M")
    result['user'] = e.user.email
    result['interaction'] = e.interaction.resource_type
    result
  end

  
end