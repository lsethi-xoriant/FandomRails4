class Easyadmin::EasyadminNoticeController < ApplicationController
  include EasyadminHelper
  include TableHelper

  layout "admin"
  
  # Constant that describe the filter available
  FIELD_DESCS = { 
    :user => FieldDesc.new({ :name => "Utente", :id => "user", :model => "user", :column_name => "email"}),
    :notice => FieldDesc.new({ :name => "Notifica", :id => "notice", :model => "notice", :column_name => "html_notice"}),
    :date => FieldDesc.new({ :name => "Data", :id => "date", :model => "notice", :column_name => "created_at"}),
    :sent => FieldDesc.new({ :name => "Inviata", :id => "sent", :model => "notice", :column_name => "last_sent"})
  }
  
  # json version of fields description
  FIELD_DESCS_JSON = (FIELD_DESCS.map { |id, obj| [id, obj.attributes] }).to_json
  
  # Return the fields description Hash
  def get_fields
    FIELD_DESCS
  end
  
  def index
    @notices = Notice.all
    @fields = FIELD_DESCS_JSON
  end

  def send(user_id, notice)
    
  end

  def mark_as_viewed
    
  end
  
  def mark_as_read
    
  end
  
  def show
    @current_notice = Notice.find(params[:id])
  end
  
  # Give back the events query result depending on conditions passes as parameter
  #
  # offset - current page results to load
  # limit  - number of results per page
  def get_results(offset, limit)
    if params[:conditions].blank?
      notices = Notice.limit(limit).offset(offset).order("updated_at DESC")
    else
      conditions = JSON.parse(params[:conditions])
      notices = build_query(conditions).limit(limit).offset(offset).order("notices.updated_at DESC")
    end
    return events
  end
  
  # construct the query to retrive events depending on filter params passed as parameter
  #
  # params - array of filter conidtions
  def build_query(params)
    query = Notice.includes(:user)
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
    result['user'] = e.user.email
    result['notice'] = e.html_notice
    result['date'] = e.created_at.strftime("%d-%m-%Y")
    result['sent'] = e.last_sent.strftime("%d-%m-%Y %H:%M")
    result
  end
  
end