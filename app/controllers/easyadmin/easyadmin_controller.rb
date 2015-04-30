class Easyadmin::EasyadminController < ApplicationController
  include EasyadminHelper
  include DateMethods

  layout "admin"

  before_filter :authorize_user
  before_filter :update_pagination_param

  def authorize_user
    authorize! :access, :easyadmin
  end

  def update_pagination_param
    @param_list = ""
    params.except(:controller, :action, :page).each do |key, value| 
      @param_list = @param_list + "&#{key}=#{value}"
    end
  end

  def index
  end
  
  def index_user
    authorize! :read, :users

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @user_list = User.page(page).per(per_page)

    @page_size = @user_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

  end
  
  def export_users
    authorize! :read, :users

    csv = "id;email;remember_created_at;sign_in_count;current_sign_in_at;last_sign_in_at;"+
        "current_sign_in_ip;last_sign_in_ip;first_name;last_name;avatar_selected;swid;privacy;confirmation_token;confirmed_at;confirmation_sent_at;"+
        "unconfirmed_email;role;authentication_token;created_at;updated_at;avatar_file_name;avatar_content_type;avatar_file_size;avatar_updated_at;"+
        "cap;location;province;address;phone;number;rule;birth_date;username;newsletter;avatar_selected_url;aux;gender\n"
    User.all.each do |user|
    csv << "#{user.id};#{user.email};#{user.remember_created_at};"+
            "#{user.sign_in_count};#{user.current_sign_in_at};#{user.last_sign_in_at};#{user.current_sign_in_ip};#{user.last_sign_in_ip};#{user.first_name};"+
            "#{user.last_name};#{user.avatar_selected};#{user.swid};#{user.privacy};#{user.confirmation_token};#{user.confirmed_at};#{user.confirmation_sent_at};"+
            "#{user.unconfirmed_email};#{user.role};#{user.authentication_token};#{user.created_at};#{user.updated_at};#{user.avatar_file_name};"+
            "#{user.avatar_content_type};#{user.avatar_file_size};#{user.avatar_updated_at};#{user.cap};#{user.location};#{user.province};#{user.address};"+
            "#{user.phone};#{user.number};#{user.rule};#{user.birth_date};#{user.username};#{user.newsletter};#{user.avatar_selected_url};#{user.aux};#{user.gender}\n"
    end
    send_data(csv, :type => 'text/csv; charset=utf-8; header=present', :filename => "users.csv")
  end

  def filter_user
    authorize! :read, :users

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20
    @user_list = User.page(page).per(per_page)

    @email_filter = params[:email_filter]
    @username_filter = params[:username_filter]

    if params[:commit] == "APPLICA FILTRO"
      where_conditions = "true"
      where_conditions << " AND email ILIKE '%#{@email_filter}%'" unless @email_filter.blank?
      where_conditions << " AND username ILIKE '%#{@username_filter}%'" unless @username_filter.blank?

      @user_list = User.where(where_conditions).page(page).per(per_page)
    else
      @email_filter = nil
      @username_filter = nil
    end

    @page_size = @user_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

    render template: "/easyadmin/easyadmin/index_user" 
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
    csv = "Nome;Cognome;Email;Indirizzo;N.Civico;Citta;Provincia;CAP;Confezioni;Tazza;N.Scontrino;Data emissione;Importo;Data richiesta\n"
    @request_list.each do |request|
    csv << "#{request["address"]["first_name"]};#{request["address"]["last_name"]};#{request["identity"]["email"]};" +
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

  def filter_tags
    conditions_string = ""
    conditions_string << "tags.title ILIKE '%#{params[:title_filter]}%'" if params[:title_filter] != "nil_title_filter"

    if params[:description_filter] != "nil_description_filter"
      where_condition = "tags.description ILIKE '%#{params[:description_filter]}%'"
      conditions_string = conditions_string.blank? ? where_condition : "#{conditions_string} and #{where_condition}"
    end

    if params[:tag_filter] != "nil_tag_filter"
      where_condition = "tagstags.name ILIKE '%#{params[:tag_filter]}%'"
      conditions_string = conditions_string.blank? ? where_condition : "#{conditions_string} and #{where_condition}"
    end

    stream_tags_to_render = Tag.where(conditions_string).all(
                              :joins => "LEFT OUTER JOIN tags_tags ON tags_tags.tag_id = tags.id
                                         LEFT OUTER JOIN tags tagstags ON tags_tags.other_tag_id = tagstags.id",
                              :group => "tags.id, tags_tags.id, tagstags.id"
                              )
    render_tags_str = ""
    stream_tags_to_render.each do |tag|
      render_tags_str = render_tags_str + (render_to_string "/easyadmin/tag/_tags_index_row", locals: { tag: tag }, layout: false, formats: :html)
    end

    respond_to do |format|
      format.json { render :json => render_tags_str.to_json }
    end
  end

  def show_user
    @user = User.find(params[:id])
  end

  def index_winner
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 30

    @instantwin_user_interactions = UserInteraction.where("cast(\"aux\"->>'instant_win_id' AS int) IS NOT NULL").page(page).per(per_page).order("updated_at ASC")
    @page_size = @instantwin_user_interactions.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def send_email_to_winner
    playticket_event = PlayticketEvent.find(params[:playticket_event_id])

    SystemMailer.win_mail(playticket_event.user, playticket_event.instantwin.contest_periodicity.instant_win_prizes.first, playticket_event.instantwin).deliver
    SystemMailer.win_admin_notice_mail(playticket_event.user, playticket_event.instantwin.contest_periodicity.instant_win_prizes.first, playticket_event.instantwin).deliver

    respond_to do |format|
      format.json { render :json => playticket_event.to_json }
    end
  end

  def index_promocode
    authorize! :manage, :promocodes
  end

  def new_promocode
    authorize! :manage, :promocodes

    @inter_promocode = Interaction.new(name: "#PRCODE#{ DateTime.now.strftime('%FT%T') }")
    @inter_promocode.resource = Promocode.new
  end

  def create_promocode
    authorize! :manage, :promocodes

    @inter_promocode = Interaction.create(params[:interaction])
    if @inter_promocode.errors.any?
      render template: "/easyadmin/easyadmin/new_promocode"     
    else
      flash[:notice] = "Promocode generato correttamente"
      redirect_to "/easyadmin/promocode"
    end
  end

  def index_tag
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 30

    @tag_list = Tag.page(page).per(per_page).order("name ASC")

    @page_size = @tag_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def edit_tag
    @tag = Tag.find(params[:id])
  end
  
  def update_class_tag_table(class_name, class_id_field, tag_id_field)
    id_objects_to_update = class_name.pluck(class_id_field)

    old_tags = params[:old_tag].split(",").map { |name|
        Tag.find_by_name(name)
    }

    old_tags.each do |old_tag|
      id_objects_tagged = class_name.where("#{tag_id_field} = ?", old_tag.id).pluck(class_id_field)
      id_objects_to_update = id_objects_to_update & id_objects_tagged # intersection
    end

    id_objects_to_update.each do |object_id|
      # class_name.delete_all(["#{class_id_field} = ?", object_id]) # uncomment if old tagging must be dismissed
      new_tag = Tag.find_by_name(params[:new_tag])
      new_tag = Tag.create(name: params[:new_tag]) unless new_tag

      if class_name.where("#{class_id_field} = ? AND #{tag_id_field} = ?", object_id, new_tag.id).count == 0
        object_tag = class_name.new
        object_tag[class_id_field] = object_id
        object_tag[tag_id_field] = new_tag.id
        object_tag.save
      end
    end

    if id_objects_to_update.size > 0
      flash.now[:notice] = (flash.now[:notice] ||= []) << "#{class_name.to_s.slice(0..-4)} ritaggati/e"
    end
  end

  def update_tags_tag_table

    id_objects_to_update = []

    params[:old_tag].split(",").map { |name|
      other_tag = Tag.find_by_name(name)
      id_objects_to_update = id_objects_to_update | TagsTag.where(:other_tag_id => other_tag.id).pluck(:tag_id)
    }

    id_objects_to_update.each do |object_id|
      # TagsTag.delete_all(["tag_id = ?", object_id]) # uncomment if old tagging must be dismissed
      new_tag = Tag.find_by_name(params[:new_tag])
      new_tag = Tag.create(name: params[:new_tag]) unless new_tag

      if TagsTag.where("tag_id = ? AND other_tag_id = ?", object_id, new_tag.id).count == 0
        object_tag = TagsTag.new
        object_tag.tag_id = object_id
        object_tag.other_tag_id = new_tag.id
        object_tag.save
      end
    end

    if id_objects_to_update.size > 0
      flash.now[:notice] = (flash.now[:notice] ||= []) << "Tags ritaggati/e"
    end
  end

  def update_tag
    @tag = Tag.find(params[:id])
    unless @tag.update_attributes(params[:tag])  
      render template: "/easyadmin/easyadmin/edit_tag"     
    else
      flash[:notice] = "Tag aggiornato correttamente"
      redirect_to "/easyadmin/tag"
    end
  end

  def tag_cta
    @tag_list_arr = Array.new
    CallToAction.find(params[:id]).call_to_action_tags.each { |t| @tag_list_arr << t.tag.name }
    @tag_list = @tag_list_arr.join(",")
    @page = params[:page]
  end

  def tag_cta_update
    cta = CallToAction.find(params[:id])
    tag_list = params[:tag_list].split(",")

    cta.call_to_action_tags.delete_all

    tag_list.each do |t|
      tag = Tag.find_by_name(t)
      tag = Tag.create(name: t, slug: t) unless tag
      CallToActionTag.create(tag_id: tag.id, call_to_action_id: cta.id)
    end
    flash[:notice] = "CallToAction taggata"
    unless params[:page].blank?
      redirect_to params[:page]
    else
      redirect_to "/easyadmin/cta/tag/#{ cta.id }"
    end
  end

  def dashboard
    authorize! :access, :dashboard
    @user_week_list = Hash.new
    if User.any? 
      if (params[:datepicker_from_date].blank? || params[:commit] == "Reset") 
        @from_date_string = (Time.now - 1.week).strftime('%m/%d/%Y')
      else
        @from_date_string = params[:datepicker_from_date]
      end
      @to_date_string = (params[:datepicker_to_date].blank? || params[:commit] == "Reset") ? Time.now.strftime('%m/%d/%Y') : params[:datepicker_to_date]
      @from_date = datetime_parsed_to_utc(DateTime.strptime("#{@from_date_string} 00:00:00 #{USER_TIME_ZONE_ABBREVIATION}", '%m/%d/%Y %H:%M:%S %z'))
      @to_date = datetime_parsed_to_utc(DateTime.strptime("#{@to_date_string} 23:59:59 #{USER_TIME_ZONE_ABBREVIATION}", '%m/%d/%Y %H:%M:%S %z'))

      from = @from_date
      to = @to_date

      if((to - from).to_i <= 7 && params[:time_interval] != "daily")
        params[:time_interval] = "daily"
      end

      while from < to - 1.day do 
        @user_week_list["#{from.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d") }"] = {
          "tot" => User.where("created_at<=?", from).count,
          "simple" => User.includes(:authentications).where("authentications.user_id IS NULL AND users.created_at<=?", from).count
          }
        from = (params[:time_interval] == "daily" && params[:commit] != "Reset") ? from + 1.day : from + 1.week
      end
      @user_week_list["#{from.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d") }"] = {
          "tot" => User.where("created_at<=?", to).count,
          "simple" => User.includes(:authentications).where("authentications.user_id IS NULL AND users.created_at<=?", to).count
          }
    end
  end

  def index_most_clicked_interactions
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    if (params[:datepicker_from_date].blank? || params[:commit] == "Reset") 
      @from_date_string = (Time.now - 1.week).strftime('%m/%d/%Y')
    else
      @from_date_string = params[:datepicker_from_date]
    end
    @to_date_string = (params[:datepicker_to_date].blank? || params[:commit] == "Reset") ? Time.now.strftime('%m/%d/%Y') : params[:datepicker_to_date]
    @from_date = datetime_parsed_to_utc(DateTime.strptime("#{@from_date_string} 00:00:00 #{USER_TIME_ZONE_ABBREVIATION}", '%m/%d/%Y %H:%M:%S %z'))
    @to_date = datetime_parsed_to_utc(DateTime.strptime("#{@to_date_string} 23:59:59 #{USER_TIME_ZONE_ABBREVIATION}", '%m/%d/%Y %H:%M:%S %z'))

    @interactions = Interaction
        .joins(:user_interactions)
        .includes(:call_to_action)
        .where("user_interactions.created_at >= '#{@from_date}' AND user_interactions.created_at <= '#{@to_date}'")
        .group("interactions.id")
        .order("SUM(user_interactions.counter) DESC")
        .select("SUM(user_interactions.counter) as count, resource_type, interactions.id, call_to_action_id")
        .page(page)
        .per(per_page)

    @page_size = @interactions.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

  end

  def index_reward_cta_unlocked

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @reward_cta_list = Reward
      .select("rewards.id, title, cost, call_to_action_id, sum(rewards.id) AS unlocked_by")
      .joins("LEFT JOIN user_rewards ON rewards.id = user_rewards.reward_id")
      .where("call_to_action_id IS NOT NULL")
      .group("rewards.id")
      .order("unlocked_by DESC")
      .page(page).per(per_page)

    @page_size = @reward_cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

  end

  def published
    authorize! :manage, :published
  end

  def show_cta
    @current_cta = CallToAction.find(params[:id])

    tag_list_arr = Array.new
    @current_cta.call_to_action_tags.each { |t| tag_list_arr << t.tag.name }
    @tag_list = tag_list_arr.join(", ")

    @trivia_answer = Hash.new
    @versus_answer = Hash.new
    @current_cta.interactions.where("resource_type='Quiz'").each do |q|
      if q.resource.quiz_type == "TRIVIA"
        @trivia_answer["#{ q.id }"] = {
          "answer_correct" => q.resource.cache_correct_answer,
          "answer_wrong" => q.resource.cache_wrong_answer
        }
      elsif q.resource.quiz_type == "VERSUS"
        @versus_answer["#{ q.id }"] = Hash.new
        sum = 0
        q.resource.answers.each { |a| sum = sum + a.user_interactions.count }
        q.resource.answers.each do |v|
          @versus_answer["#{ q.id }"]["#{ v.id }"] = {
            "answer" => v.text,
            "perc" => ((v.user_interactions.count.to_f/sum.to_f*100))
          }
        end
      end
    end

  end

  def get_current_month_event
    month_calltoaction_list = CallToAction.select("activated_at, id, title").where("activated_at<? AND activated_at>=?", (Time.parse(params["time"]).to_date + 2.month).change(day: 1).strftime("%Y/%m/%d"), (Time.parse(params["time"]).to_date - 1.month).change(day: 1).strftime("%Y/%m/%d"))
    respond_to do |format|
      format.json { render :json => month_calltoaction_list.to_json }
    end
  end

  def update_activated_at
    cta = CallToAction.find(params[:id])
    cta.activation_date_time = DateTime.parse(params["time"]).to_s
    cta.save
    respond_to do |format|
      format.json { render :json => "calltoaction-update".to_json }
    end
  end

  def index_cta
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @cta_list = CallToAction.page(page).per(per_page).order("activated_at DESC NULLS LAST")

    @page_size = @cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def filter_cta
    cta_filter_list = CallToAction.where("title LIKE ?", "%#{ params[:filter] }%").order("activated_at DESC").limit(5)

    risp = Hash.new
    cta_filter_list.each do |cta|
      risp["#{cta.id}"] = {
          "title" => cta.title,
          "activated_at" => cta.activated_at,
          "image" => cta.image.url
        }
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end

=begin

  def new_cta
    @cta = CallToAction.new
  end

  def edit_cta
    @cta = CallToAction.find(params[:id])

    @tag_list_arr = Array.new
    @cta.call_to_action_tags.each { |t| @tag_list_arr << t.tag.name }
    @tag_list = @tag_list_arr.join(",")
  end

  def hide_cta
    cta = CallToAction.find(params[:id])
    if cta.activated_at.blank?
      risp = "active"
      cta.update_attribute("activated_at", DateTime.now.change(hour: 0))
    else
      risp = "not-active"
      cta.update_attribute("activated_at", nil)
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end

  def save_cta
    @cta = CallToAction.create(params[:call_to_action])
    if @cta.errors.any?
      @tag_list = params[:tag_list].split(",")

      render template: "/easyadmin/call_to_action/new_cta"     
    else

      tag_list = params[:tag_list].split(",")
      @cta.call_to_action_tags.delete_all
      tag_list.each do |t|
        tag = Tag.find_by_name(t)
        tag = Tag.create(name: t) unless tag
        CallToActionTag.create(tag_id: tag.id, call_to_action_id: @cta.id)
      end

      flash[:notice] = "CallToAction generata correttamente"
      redirect_to "/easyadmin/cta/show/#{ @cta.id }"
    end
  end

  def update_cta
    @cta = CallToAction.find(params[:id])
    unless @cta.update_attributes(params[:call_to_action])
      @tag_list = params[:tag_list].split(",")
    
      render template: "/easyadmin/easyadmin/edit_cta"   
    else

      tag_list = params[:tag_list].split(",")
      @cta.call_to_action_tags.delete_all
      tag_list.each do |t|
        tag = Tag.find_by_name(t)
        tag = Tag.create(name: t) unless tag
        CallToActionTag.create(tag_id: tag.id, call_to_action_id: @cta.id)
      end

      flash[:notice] = "CallToAction aggiornata correttamente"
      redirect_to "/easyadmin/cta/show/#{ @cta.id }"
    end
  end

=end

  def new_periodicity
    @periodicity = PeriodicityType.new
  end

  def save_periodicity
    @periodicity = PeriodicityType.create(params[:periodicity_type])
    if @periodicity.errors.any?
      render template: "/easyadmin/easyadmin/periodicity/new"
    else
      flash[:notice] = "periodicity generata correttamente"
      redirect_to "/easyadmin/periodicity"
    end
  end

  def index_periodicity
    @periodicity_list = PeriodicityType.order("period ASC")
  end

  def index_contest
    @contest_list = Contest.order("created_at DESC")
  end

  def new_contest
    @contest = Contest.new
  end

  def save_contest
    @contest = Contest.create(params[:contest])
    if @contest.errors.any?
      render template: "new_contest"     
    else
      flash[:notice] = "Concorso generato correttamente"
      redirect_to "/easyadmin/contest"
    end
  end

  def index_prize
    @prize_list = InstantWinPrize.order("contest_periodicity_id ASC")
  end

  def new_prize
    @prize = InstantWinPrize.new
  end

  def save_prize
    @prize = InstantWinPrize.create(params[:prize])
    if @prize.errors.any?
      render template: "new_contest"     
    else
      flash[:notice] = "Premio inserito correttamente"
      redirect_to "/easyadmin/prize"
    end
  end

  def edit_prize
    @prize = InstantWinPrize.find(params[:id])
  end

  def update_prize
    @prize = InstantWinPrize.find(params[:id])
    unless @prize.update_attributes(params[:prize])  
      render template: "/easyadmin/easyadmin/edit_prize"     
    else
      flash[:notice] = "Premio aggiornato correttamente"
      redirect_to "/easyadmin/prize"
    end
  end

end