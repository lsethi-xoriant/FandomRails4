class Easyadmin::EasyadminController < ApplicationController
  include EasyadminHelper

  layout "admin"

  before_filter :authorize_user
  before_filter :update_pagination_param, only: :index_cta

  INTERACTION_TYPE = ["TRIVIA", "VERSUS", "LIKE", "CHECK", "SHARE", "PLAY", "DOWNLOAD"]

  def authorize_user
    authorize! :manage, :all
  end

  def update_pagination_param
      @param_list = ""
      params.except(:controller, :action, :page).each do |key, value| 
        @param_list = @param_list + "&#{key}=#{value}"
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

    @tag_list = Tag.page(page).per(per_page).order("text ASC")

    @page_size = @tag_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def edit_tag
    @tag = Tag.find(params[:id])
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
    Calltoaction.find(params[:id]).calltoaction_tags.each { |t| @tag_list_arr << t.tag.text }
    @tag_list = @tag_list_arr.join(",")
  end

  def tag_cta_update
    calltoaction = Calltoaction.find(params[:id])
    tag_list = params[:tag_list].split(",")

    calltoaction.calltoaction_tags.delete_all

    tag_list.each do |t|
      tag = Tag.find_by_text(t)
      tag = Tag.create(text: t) unless tag
      CalltoactionTag.create(tag_id: tag.id, calltoaction_id: calltoaction.id)
    end
    flash[:notice] = "Calltoaction taggata"
    redirect_to "/easyadmin/cta/tag/#{ calltoaction.id }"
  end

  def dashboard
    @user_week_list = Hash.new
    if User.any?
      time = User.order("created_at ASC").limit(1).first.created_at.strftime("%Y-%m-%d")
      while time.to_date < Time.now.to_date do
        @user_week_list["#{ time.to_date.strftime("%Y-%m-%d") }"] = {
          "tot" => User.where("created_at<=?", time).count,
          "simple" => User.includes(:authentications).where("authentications.user_id IS NULL AND users.created_at<=?", time).count
          }
        time = time.to_date + 1.week
      end
    end
  end

  def published
  end

  def show_property
    @current_prop = Property.find(params[:id])

    @user_week_list = Hash.new
    unless @current_prop.rewarding_users.blank?
      time =  @current_prop.rewarding_users.order("created_at ASC").limit(1).first.created_at.strftime("%Y-%m-%d")
      while time.to_date < Time.now.to_date do
        @user_week_list["#{ time.to_date.strftime("%Y-%m-%d") }"] = @current_prop.rewarding_users.where("created_at<=?", time).count
        time = time.to_date + 1.week
      end
    end
  end

  def show_cta
    @current_cta = Calltoaction.find(params[:id])

    tag_list_arr = Array.new
    @current_cta.calltoaction_tags.each { |t| tag_list_arr << t.tag.text }
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
        q.resource.answers.each { |a| sum = sum + a.userinteractions.count }
        q.resource.answers.each do |v|
          @versus_answer["#{ q.id }"]["#{ v.id }"] = {
            "answer" => v.text,
            "perc" => ((v.userinteractions.count.to_f/sum.to_f*100))
          }
        end
      end
    end

  end

  def new_badge
    @current_prop = Property.find(params[:id])
    @badge = Badge.new
  end

  def new_level
    @current_prop = Property.find(params[:id])
    @level = Level.new
  end

  def edit_badge
    @current_prop = Property.find(params[:id])
    @badge = Badge.find(params[:badge_id])
  end

  def edit_level
    @current_prop = Property.find(params[:id])
    @level = Level.find(params[:level_id])
  end

  def save_level
    @level = Level.create(params[:level])
    if @level.errors.any?
      @current_prop = Property.find(@level.property_id)
      render template: "/easyadmin/easyadmin/new_level"     
    else
      flash[:notice] = "Livello aggiunto correttamente"
      redirect_to "/easyadmin/property/show/#{ @level.property_id }"
    end
  end

  def save_badge
    @badge = Badge.create(params[:badge])
    if @badge.errors.any?
      @current_prop = Property.find(@badge.property_id)
      render template: "/easyadmin/easyadmin/new_badge"     
    else
      flash[:notice] = "Badge aggiunto correttamente"
      redirect_to "/easyadmin/property/show/#{ @badge.property_id }"
    end
  end

  def update_badge
    @badge = Badge.find(params[:badge_id])
    unless @badge.update_attributes(params[:badge])  
      render template: "/easyadmin/easyadmin/edit_badge"     
    else
      flash[:notice] = "Badge aggiornato correttamente"
      redirect_to "/easyadmin/property/show/#{ @badge.property_id }"
    end
  end

  def update_level
    @level = Level.find(params[:level_id])
    unless @level.update_attributes(params[:level])  
      render template: "/easyadmin/easyadmin/edit_level"     
    else
      flash[:notice] = "Livello aggiornato correttamente"
      redirect_to "/easyadmin/property/show/#{ @level.property_id }"
    end
  end

  def destroy_badge
    badge = Badge.find(params[:id])
    badge.destroy

    respond_to do |format|
      format.json { render :json => badge.to_json }
    end
  end

  def destroy_level
    level = Level.find(params[:id])
    level.destroy

    respond_to do |format|
      format.json { render :json => level.to_json }
    end
  end

  def get_current_month_event
    month_calltoaction_list = Calltoaction.select("activated_at, id, title").where("activated_at<? AND activated_at>=?", (Time.parse(params["time"]).to_date + 2.month).change(day: 1).strftime("%Y/%m/%d"), (Time.parse(params["time"]).to_date - 1.month).change(day: 1).strftime("%Y/%m/%d"))
    respond_to do |format|
      format.json { render :json => month_calltoaction_list.to_json }
    end
  end

  def update_activated_at
    cta = Calltoaction.find(params[:id])
    cta.update_attribute(:activated_at, Time.parse(params["time"]).to_date)
    respond_to do |format|
      format.json { render :json => "calltoaction-update".to_json }
    end
  end

  def index_cta
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @current_prop = params[:property] unless params[:property].blank?
    unless @current_prop
      @cta_list = Calltoaction.page(page).per(per_page).order("activated_at DESC")
    else
      @cta_list = Calltoaction.where("property_id=?", params[:property]).page(page).per(per_page).order("activated_at DESC")
    end

    @page_size = @cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def filter_cta
    if params[:property].blank?
      cta_filter_list = Calltoaction.where("title LIKE ?", "%#{ params[:filter] }%").order("activated_at DESC").limit(5)
    else
      cta_filter_list = Calltoaction.where("title LIKE ? AND property_id=?", "%#{ params[:filter] }%", params[:property]).order("activated_at DESC").limit(5)
    end

    risp = Hash.new
    cta_filter_list.each do |cta|
      risp["#{cta.id}"] = {
          "propertyname" => cta.property.name,
          "title" => cta.title,
          "activated_at" => cta.activated_at,
          "image" => cta.image.url
        }
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end

  def index_property
    @property_list = Property.order("created_at DESC")
  end

  def new_cta
    @current_prop = Property.find(params[:property])
    @cta = Calltoaction.new(property_id: @current_prop.id)
  end

  def new_property
    @property = Property.new
    INTERACTION_TYPE.each do |i|
      @property.default_interaction_points.build(interaction_type: i)
    end
  end

  def edit_cta
    @cta = Calltoaction.find(params[:id])
    @current_prop = Property.find(@cta.property_id)

    @tag_list_arr = Array.new
    @cta.calltoaction_tags.each { |t| @tag_list_arr << t.tag.text }
    @tag_list = @tag_list_arr.join(",")
  end

  def edit_property
    @property = Property.find(params[:id])
    INTERACTION_TYPE.each do |i|
      @property.default_interaction_points.build(interaction_type: i) unless @property.default_interaction_points.find_by_interaction_type(i)
    end
  end

  def hide_cta
    cta = Calltoaction.find(params[:id])
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
    @cta = Calltoaction.create(params[:calltoaction])
    if @cta.errors.any?
      @tag_list = params[:tag_list].split(",")
      @current_prop = Property.find(@cta.property_id)
      params[:property] = @current_prop.id

      render template: "/easyadmin/easyadmin/new_cta"     
    else

      tag_list = params[:tag_list].split(",")
      @cta.calltoaction_tags.delete_all
      tag_list.each do |t|
        tag = Tag.find_by_text(t)
        tag = Tag.create(text: t) unless tag
        CalltoactionTag.create(tag_id: tag.id, calltoaction_id: @cta.id)
      end

      flash[:notice] = "Calltoaction generata correttamente"
      redirect_to "/easyadmin/cta/show/#{ @cta.id }"
    end
  end

  def save_property
    @property = Property.create(params[:property])
    if @property.errors.any?
      render template: "/easyadmin/easyadmin/new_property"     
    else
      flash[:notice] = "Property generata correttamente"
      redirect_to "/easyadmin/property"
    end
  end

  def update_cta
    @cta = Calltoaction.find(params[:id])
    unless @cta.update_attributes(params[:calltoaction])
      @tag_list = params[:tag_list].split(",")
      @current_prop = Property.find(@cta.property_id)  
      params[:property] = @current_prop.id

      render template: "/easyadmin/easyadmin/edit_cta"   
    else

      tag_list = params[:tag_list].split(",")
      @cta.calltoaction_tags.delete_all
      tag_list.each do |t|
        tag = Tag.find_by_text(t)
        tag = Tag.create(text: t) unless tag
        CalltoactionTag.create(tag_id: tag.id, calltoaction_id: @cta.id)
      end

      flash[:notice] = "Calltoaction aggiornata correttamente"
      redirect_to "/easyadmin/cta/show/#{ @cta.id }"
    end
  end

  def update_property
    @property = Property.find(params[:id])
    unless @property.update_attributes(params[:property])
      render template: "/easyadmin/easyadmin/edit_property"     
    else
      flash[:notice] = "Property aggiornata correttamente"
      redirect_to "/easyadmin/property"
    end
  end

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
    debugger
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

  def update_comment_pubblished
    comm = UserComment.find(params[:property].to_i)
    comm.update_attributes(published_at: DateTime.now, deleted: params[:pub_or_hide] == "hide")

    respond_to do |format|
      format.json { render :json => comm.to_json }
    end
  end

  def index_comment_not_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    unless params[:property].blank?
      @current_prop = Property.find(params[:property].to_i)
      @comment_not_approved = UserComment.includes(:comment => { :interaction => :calltoaction }).where("calltoactions.property_id=? AND user_comments.deleted=true", params[:property]).page(page).per(per_page).order("user_comments.created_at ASC")
    else
      @comment_not_approved = UserComment.where("deleted=true", params[:id]).page(page).per(per_page).order("created_at ASC")
    end

    @page_size = @comment_not_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_to_be_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    unless params[:property].blank?
      @current_prop = Property.find(params[:property].to_i)
      @comment_to_be_approved = UserComment.includes(:comment => { :interaction => :calltoaction }).where("calltoactions.property_id=? AND user_comments.published_at IS NULL", params[:property]).page(page).per(per_page).order("user_comments.created_at ASC")
    else
      @comment_to_be_approved = UserComment.where("published_at IS NULL", params[:id]).page(page).per(per_page).order("created_at ASC")
    end

    @page_size = @comment_to_be_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def index_comment_approved
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    unless params[:property].blank?
      @current_prop = Property.find(params[:property].to_i)
      @comment_approved = UserComment.includes(:comment => { :interaction => :calltoaction }).where("calltoactions.property_id=? AND user_comments.published_at IS NOT NULL AND user_comments.deleted=false", params[:property]).page(page).per(per_page).order("user_comments.created_at ASC")
    else
      @comment_approved = UserComment.where("published_at IS NOT NULL AND deleted=false", params[:id]).page(page).per(per_page).order("created_at ASC")
    end

    @page_size = @comment_approved.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end


end