class Easyadmin::EasyadminNoticeController < ApplicationController
  include EasyadminHelper
  include TableHelper

  layout "admin"
  
  # Constant that describe the filter available
  FIELD_DESCS = {
    :user => FieldDesc.new({ :name => "Utente", :id => "user", :model => "user", :column_name => "email", :visible => true}),
    :notice => FieldDesc.new({ :name => "Notifica", :id => "notice", :model => "notice", :column_name => "html_notice", :visible => true}),
    :date => FieldDesc.new({ :name => "Data", :id => "date", :model => "notice", :column_name => "created_at", :visible => true}),
    :sent => FieldDesc.new({ :name => "Inviata", :id => "sent", :model => "notice", :column_name => "last_sent", :visible => true})
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
  
  def show
    @current_notice = Notice.find(params[:id])
  end
  
  def new
  end
  
  def create
    if params[:users].blank? || params[:notice].blank?
      notice[:error] = "ERRORE: Devi inserire sia mail utenti che l'html della notifica."
    else
      params[:users].split(",").each do |u|
        user = User.find_by_email(u)
        if user
          notice = Notice.create(:user_id => user.id, :html_notice => params[:notice], :viewed => false, :read => false)
          notice.send_to_user(request)
        end
      end
      flash[:notice] = "Notifiche inviate correttamente"
    end 
    render template: "/easyadmin/easyadmin_notice/new"
  end
  
  def resend_notice
    notice = Notice.find(params[:notice_id])
    notice.send_to_user(request)
    respond_to do |format|
      format.json { render :json => "OK".to_json }
    end
  end
  
  # Give back the events query result depending on conditions passes as parameter and the count of total elements
  # that match the conditions
  #
  # offset - current page results to load
  # limit  - number of results per page
  def get_results(offset, limit)
    result = Hash.new
    total = 0
    if params[:conditions].blank?
      total = Notice.count      
      notices = Notice.limit(limit).offset(offset).order("updated_at DESC")
    else
      conditions = JSON.parse(params[:conditions])
      total = build_query(conditions).count
      notices = build_query(conditions).limit(limit).offset(offset).order("notices.updated_at DESC")
    end
    result['total'] = total
    result['elements'] = notices
    return result
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
    result['notice_id'] = e.id
    result['user'] = e.user.email
    result['notice'] = e.html_notice
    result['date'] = e.created_at.strftime("%d-%m-%Y")
    result['sent'] = e.last_sent.nil? ? "" : e.last_sent.strftime("%d-%m-%Y %H:%M")
    result
  end
  
end