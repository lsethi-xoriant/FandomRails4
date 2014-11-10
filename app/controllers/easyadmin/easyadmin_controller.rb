class Easyadmin::EasyadminController < ApplicationController
  include EasyadminHelper
  include DateMethods

  layout "admin"

  before_filter :authorize_user
  before_filter :update_pagination_param, only: :index_cta

  def authorize_user
    authorize! :access, :easyadmin
  end

  def update_pagination_param
      @param_list = ""
      params.except(:controller, :action, :page).each do |key, value| 
        @param_list = @param_list + "&#{key}=#{value}"
      end
  end

  def show_user
    @user = User.find(params[:id])
  end

  def index_winner
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 30

    @playticket_events = PlayticketEvent.where("winner=true").page(page).per(per_page).order("created_at ASC")

    @page_size = @playticket_events.num_pages
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
  end

  def new_promocode
    @inter_promocode = Interaction.new(name: "#PRCODE#{ DateTime.now.strftime("%Y%m%d") }")
    @inter_promocode.resource = Promocode.new
  end

  def create_promocode
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
  
  def retag_tag
    if params[:commit] == "RITAGGA"

      if params[:old_tags_id_list].blank?
        msg = "Tag da ricercare non inseriti"
        flash.now[:error] = (flash.now[:error] ||= []) << msg
      elsif params[:new_tag].is_a?(Array)
        msg = "Inserire un solo nuovo tag"
        flash.now[:error] = (flash.now[:error] ||= []) << msg
      end
      if params[:new_tag].blank?
        msg = "Nuovo tag non inserito"
        flash.now[:error] = (flash.now[:error] ||= []) << msg
      end

      if params[:old_tags_id_list].present? && params[:new_tag].present? 

        update_class_tag_table(CallToActionTag, "call_to_action_id", "tag_id")
        update_class_tag_table(RewardTag, "reward_id", "tag_id")
        update_class_tag_table(TagsTag, "tag_id", "other_tag_id")

      end

    end
  end
  
  def update_class_tag_table(class_name, class_id_field, tag_id_field)
    id_objects_to_update = class_name.pluck(class_id_field)
    old_tags_array = params[:old_tags_id_list].split(",").map(&:to_i)

    old_tags_array.each do |tag_id|
      id_objects_tagged = class_name.where("#{tag_id_field} = ?", tag_id).pluck(class_id_field)
      id_objects_to_update = id_objects_to_update & id_objects_tagged # intersection
    end

    id_objects_to_update.each do |object_id|
      # class_name.delete_all(["#{class_id_field} = ?", object_id]) # uncomment if old tagging must be dismissed
      new_tag = is_an_integer?(params[:new_tag]) ? Tag.find_by_id(params[:new_tag]) : Tag.find_by_name(params[:new_tag])
      new_tag = Tag.create(name: params[:new_tag]) unless new_tag

      if class_name.where("#{class_id_field} = ? AND #{tag_id_field} = ?", object_id, new_tag.id).count == 0
        object_tag = class_name.new
        object_tag[class_id_field] = object_id
        object_tag[tag_id_field] = new_tag.id
        object_tag.save
      end
    end

    if id_objects_to_update.size > 0
      flash.now[:notice].nil? ? flash.now[:notice] = ["#{class_name.to_s.slice(0..-4)} ritaggati/e"] 
                              : flash.now[:notice] << "#{class_name.to_s.slice(0..-4)} ritaggati/e"
    end
  end
  
  def is_an_integer?(str)
    !!(str =~ /\A[-+]?[0-9]+\z/)
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
  end

  def tag_cta_update
    calltoaction = CallToAction.find(params[:id])
    tag_list = params[:tag_list].split(",")

    calltoaction.call_to_action_tags.delete_all

    tag_list.each do |t|
      tag = Tag.find_by_name(t)
      tag = Tag.create(name: t) unless tag
      CallToActionTag.create(tag_id: tag.id, calltoaction_id: calltoaction.id)
    end
    flash[:notice] = "CallToAction taggata"
    redirect_to "/easyadmin/cta/tag/#{ calltoaction.id }"
  end

  def dashboard
    @user_week_list = Hash.new
    if User.any? 
      @from_date_string = (params[:datepicker_from_date].blank? || params[:commit] == "Reset") ? 
                              User.order("created_at ASC").limit(1).first.created_at.strftime('%m/%d/%Y')
                          : params[:datepicker_from_date]
      @to_date_string = (params[:datepicker_to_date].blank? || params[:commit] == "Reset") ? 
                              Time.now.strftime('%m/%d/%Y')
                          : params[:datepicker_to_date]

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

    @interaction_list = Interaction.joins(:user_interactions).group("interactions.id").order("SUM(user_interactions.counter) DESC").page(page).per(per_page)

    @page_size = @interaction_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

  end

  def index_reward_cta_unlocked

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @reward_cta_list = Reward.where("media_type ILIKE 'CallToAction'").page(page).per(per_page)

    @page_size = @reward_cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

  end

  def published
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
    cta.update_attribute(:activated_at, Time.parse(params["time"]).to_date)
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