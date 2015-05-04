class Sites::Orzoro::Easyadmin::UserController < Easyadmin::EasyadminController
  include EasyadminHelper
  include DateMethods
  include FilterHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :read, :users
  end

  def index_cup_requests
    @request_list = []
    User.all.each do |user|
      cups_redeemed = JSON.parse(user.aux)["cup_redeem"] rescue nil
      if cups_redeemed
        cups_redeemed.each do |entry|
          if entry["receipt"]
            @request_list += [entry]
          end
        end
      end
    end
  end

  def export_cup_requests
    @request_list = build_request_list(params[:where_conditions], params[:from_date], params[:to_date])
    csv = "Nome;Cognome;Giorno di nascita;Mese di nascita;Anno di nascita;Gender;Email;Indirizzo;N.Civico;Citta;Provincia;CAP;" + 
          "Confezioni;Gadget;N.Scontrino;Data emissione;Importo;Data richiesta\n"
    @request_list.each do |request|
    csv << "#{request["address"]["first_name"]};#{request["address"]["last_name"]};" +
            "#{request["identity"]["day_of_birth"]};#{request["month_of_birth"]["email"]};#{request["identity"]["year_of_birth"]};#{request["identity"]["email"]};" +
            "#{request["identity"]["gender"]}"
            "#{request["address"]["address"]};#{request["address"]["street_number"]};#{request["address"]["city"]};#{request["address"]["province"]};" +
            "#{request["address"]["cap"]};#{request["receipt"]["package_count"]};#{request["receipt"]["cup_selected"]};#{request["receipt"]["receipt_number"]};" + 
            "#{(sprintf '%02d', request["receipt"]["day_of_emission"])}/#{(sprintf '%02d', request["receipt"]["month_of_emission"])}/#{request["receipt"]["year_of_emission"]} #{(sprintf '%02d', request["receipt"]["hour_of_emission"])}:#{request["receipt"]["minute_of_emission"]};" +
            "#{request["receipt"]["receipt_total"]};#{Time.parse(request["request_timestamp"]).strftime("%d/%m/%Y") rescue ''}\n"
    end
    send_data(csv, :type => 'text/csv; charset=utf-8; header=present', :filename => "cup_requests.csv")
  end

  def filter_cup_requests
    @email_filter = params[:email_filter]
    @from_date = params[:datepicker_from_date]
    @to_date = params[:datepicker_to_date]
    where_conditions = ""

    if params[:commit] == "APPLICA FILTRO"  
      where_conditions << "email ILIKE '%#{@email_filter}%'" unless @email_filter.blank?
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
    request_list
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