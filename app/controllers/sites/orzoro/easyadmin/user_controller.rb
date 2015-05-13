class Sites::Orzoro::Easyadmin::UserController < Easyadmin::EasyadminController
  include EasyadminHelper
  include DateMethods
  include FilterHelper
  include OrzoroHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :read, :users
  end

  def index_cup_requests
    @page = params[:page]
    if @page == "confirmed"
      users = User.where("confirmed_at IS NOT NULL")
    elsif @page == "not_confirmed"
      users = User.where("confirmed_at IS NULL")
    end
    request_list = []
    users.each do |user|
      cups_redeemed = JSON.parse(user.aux)["cup_redeem"] rescue nil
      if cups_redeemed
        cups_redeemed.each do |entry|
          if entry["receipt"]
            request_list += [entry]
          end
        end
      end
    end
    @request_list = request_list.sort_by { |h| Time.parse(h["request_timestamp"]) rescue Time.now }.reverse!
  end

  def export_cup_requests
    where_conditions = "confirmed_at IS#{" NOT" if params[:page] == "confirmed"} NULL"
    where_conditions << " AND email ILIKE '%#{params[:email_filter]}%'" unless params[:email_filter].blank?
    @request_list = build_request_list(where_conditions, params[:from_date], params[:to_date])

    csv = "ID;Nome;Cognome;Giorno di nascita;Mese di nascita;Anno di nascita;Gender;Stato;Provincia;Telefono;Email;Terms;Newsletter;Privacy;" + 
          "Confezioni;Gadget;N.Scontrino;Data emissione;Importo;Data richiesta;Nome sped.;Cognome sped.;Indirizzo sped.;N.Civico sped.;" + 
          "Citta sped.;Provincia sped.;CAP sped.\n"

    @request_list.each do |request|
    csv << "#{User.find_by_email(request["identity"]["email"]).id rescue ""};#{request["identity"]["first_name"]};#{request["identity"]["last_name"]};" +
            "#{request["identity"]["day_of_birth"]};#{request["identity"]["month_of_birth"]};#{request["identity"]["year_of_birth"]};" +
            "#{request["identity"]["gender"]};#{request["identity"]["state"]};#{request["identity"]["province"]};#{request["identity"]["phone"]};#{request["identity"]["email"]};" +
            "#{request["identity"]["terms"]};#{request["identity"]["newsletter"]};#{request["identity"]["privacy"]};#{request["receipt"]["package_count"]};#{get_request_selection(request["receipt"]["cup_selected"])};#{request["receipt"]["receipt_number"]};" + 
            "#{(sprintf '%02d', request["receipt"]["day_of_emission"])}/#{(sprintf '%02d', request["receipt"]["month_of_emission"])}/#{request["receipt"]["year_of_emission"]} #{(sprintf '%02d', request["receipt"]["hour_of_emission"])}:#{request["receipt"]["minute_of_emission"]};" +
            "#{request["receipt"]["receipt_total"]};#{Time.parse(request["request_timestamp"]).strftime("%d/%m/%Y") rescue ""};#{request["address"]["first_name"]};#{request["address"]["last_name"]};" + 
            "#{request["address"]["address"]};#{request["address"]["street_number"]};#{request["address"]["city"]};#{request["address"]["province"]};#{request["address"]["cap"]}\n"
    end
    send_data(csv, :type => 'text/csv; charset=utf-8; header=present', :filename => "cup_requests.csv")
  end

  def filter_cup_requests
    @page = params[:page]
    @email_filter = params[:email_filter]
    @from_date = params[:datepicker_from_date]
    @to_date = params[:datepicker_to_date]
    where_conditions = "confirmed_at IS#{" NOT" if @page == "confirmed"} NULL"

    if params[:commit] == "APPLICA FILTRO"  
      where_conditions << " AND email ILIKE '%#{@email_filter}%'" unless @email_filter.blank?
    else
      @email_filter = @from_date = @to_date = nil
    end
    @request_list = build_request_list(where_conditions, @from_date, @to_date)
    render template: "/easyadmin/easyadmin/index_cup_requests" 
  end

  def build_request_list(where_conditions, from_date, to_date)
    request_list = []
    users = where_conditions.blank? ? User.all : User.where(where_conditions)
    users.each do |user|
      cups_redeemed = JSON.parse(user.aux)["cup_redeem"] rescue nil
      if cups_redeemed.present?
        cups_redeemed.each do |request|
          if request["receipt"] && request_timestamp_between_dates(request["request_timestamp"], from_date, to_date)
            request_list += [request]
          end
        end
      end
    end
    request_list.sort_by { |h| Time.parse(h["request_timestamp"]) rescue Time.now }.reverse!
  end

  def request_timestamp_between_dates(timestamp, from_date, to_date)
    if from_date.blank? || to_date.blank?
      return true
    elsif timestamp.nil?
      return false
    end
    request_timestamp = Time.parse(timestamp)
    after_from_date = from_date.nil? ? true : request_timestamp >= DateTime.strptime(from_date, "%m/%d/%Y")
    before_to_date = to_date.nil? ? true : request_timestamp <= DateTime.strptime(to_date, "%m/%d/%Y").change({ hour: 23, min: 59, sec: 59 })
    return after_from_date && before_to_date
  end
end