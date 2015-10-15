class Easyadmin::EasyadminNoticeController < Easyadmin::EasyadminController
  include EasyadminHelper
  include TableHelper
  include NoticeHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :manage, :notices
  end

  # Constant that describes available filters
  FIELD_DESCS = {
    :user => FieldDesc.new({ :name => "Utente", :id => "user", :model => "user", :column_name => "email", :visible => true}),
    :notice => FieldDesc.new({ :name => "Notifica", :id => "notice", :model => "notice", :column_name => "html_notice", :visible => true}),
    :date => FieldDesc.new({ :name => "Data", :id => "date", :model => "notice", :column_name => "created_at", :visible => true}),
    :sent => FieldDesc.new({ :name => "Inviata", :id => "sent", :model => "notice", :column_name => "last_sent", :visible => true})
  }

  # JSON version of fields description
  FIELD_DESCS_JSON = (FIELD_DESCS.map { |id, obj| [id, obj.attributes] }).to_json

  # Returns the fields description Hash
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
    @channels_hash = JSON.parse(Setting.find_by_key(CHANNELS_SETTINGS_KEY).value) rescue {}
    @channels = @channels_hash.select { |key, value| value }.keys # the true ones
  end

  def create
    @channels_hash = JSON.parse(Setting.find_by_key(CHANNELS_SETTINGS_KEY).value) rescue {}
    @channels = @channels_hash.select { |key, value| value }.keys # the true ones
    notification_channels = get_channels_from_params(params, @channels_hash)

    if notification_channels.empty?
      flash[:error] = "ERRORE: Devi selezionare i canali di invio"
    else
      notification_channels.each do |c|
        flash[:error] = "ERRORE: Devi inserire il testo della notifica #{c}" if params[c + "_notice"].blank?
      end
      unless flash[:error]
        if params[:all_users]
          send_notifications(notification_channels, params, true)
          flash[:notice] = "Notifiche inviate correttamente"
        else
          flash[:error] = "ERRORE: Inserisci le mail degli utenti" if params[:users].blank?
          unless flash[:error]
            send_notifications(notification_channels, params)
            flash[:notice] = "Notifiche inviate correttamente"
          end
        end
      end
    end
    render template: "/easyadmin/easyadmin_notice/new"
  end

  def get_channels_from_params(params, channels_hash)
    res = []
    channels_hash.each do |key, value|
      if params[key]
        res << key if params[key] == "1"
      end
    end
    res
  end

  def send_notifications(notification_channels, params, all = false)
    if notification_channels.include?("facebook")
      facebook_settings = get_deploy_setting("sites/#{$site.id}/authentications/facebook", nil)
      if facebook_settings
        app_access_token = Koala::Facebook::API.new(
          Koala::Facebook::OAuth.new(facebook_settings["app_id"], facebook_settings["app_secret"]).get_app_access_token
        )
      end
    end

    property = get_property()
    if property
      property_name = property.name
    end

    users = all ? User.all : User.where("email IN (?)", params[:users].split(",")).to_a

    users.each do |user|
      if notification_channels.include?("fandom")
        notice = create_notice(
          :user_id => user.id, 
          :viewed => false, 
          :read => false, 
          :aux => {
            :ref_type => nil, 
            :ref_id => nil, 
            :property => property_name, 
            :text => params[:fandom_notice]
          }
        )
      end
      if notification_channels.include?("email")
        if (JSON.parse(user.aux)['subscriptions']['notifications'] rescue true)
          property = get_property()
          if property
            site_name = property.title
          else
            site_name = $site.id.capitalize
          end
          SystemMailer.notification_mail(user.email, params[:email_notice], "Hai ricevuto una notifica su #{site_name}").deliver
        end
      end
      if app_access_token
        user_fb_id = Authentication.where(:provider => "facebook", :user_id => user.id).first.oauth_token rescue nil
        app_access_token.put_connections(user_fb_id, "notifications", template: params[:facebook_notice], href: nil) if user_fb_id
      end
    end
  end

  def resend_notice
    @channels_hash = JSON.parse(Setting.find_by_key(CHANNELS_SETTINGS_KEY).value) rescue {}
    @channels = @channels_hash.select { |key, value| value }.keys # the true ones

    notice = Notice.find(params[:notice_id])
    if notice
      @fandom_notice = @email_notice = notice.html_notice
      @facebook_notice = strip_tags(notice.html_notice).strip
      params["fandom"] = "1"
    end
    render template: "/easyadmin/easyadmin_notice/new"
  end

  # Gives back the events query result depending on conditions passed as parameter and total elements
  # that match the conditions count
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

  # Constructs the query to retrieve events depending on filter params passed as parameter
  #
  # params - array of filter conditions
  def build_query(params)
    query = Notice.includes(:user).references(:user)
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

  # Converts an resultset element into a Hash in order to easily convert to JSON response
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