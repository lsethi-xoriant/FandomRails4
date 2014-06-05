
class Easyadmin::EasyadminEventConsoleController < ApplicationController
  include EasyadminHelper
  include TableHelper

  layout "admin"
    
  def get_fields
    { 
      :date => FieldDesc.new({ :name => "Data", :id => "date", :model => "userinteraction", :column_name => "updated_at"}),
      :user => FieldDesc.new({ :name => "Utente", :field => "email", :model => "user", :column_name => "email"}),
      :interaction => FieldDesc.new({ :name => "Interazione", :field => "interaction", :model => "interaction", :column_name => "resource_type" })
    }
  end
  
  def index
    @interaction_type_options = Interaction.uniq.pluck(:resource_type)
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
      query = query.where( get_active_record_expression(fields[field_id]['column_name'], operator, fields[field_id]['model']), operand )
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