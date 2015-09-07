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

  def dashboard
    authorize! :access, :dashboard

    if User.any? 

      @multiproperty = get_property().present?

      if (params[:datepicker_from_date].blank? || params[:commit] == "Reset") 
        @from_date_string = (Time.now - 1.week).strftime('%m/%d/%Y')
      else
        @from_date_string = params[:datepicker_from_date]
      end
      @to_date_string = (params[:datepicker_to_date].blank? || params[:commit] == "Reset") ? 
                          Time.now.strftime('%m/%d/%Y')
                            : params[:datepicker_to_date]

      @from_date = DateTime.strptime("#{@from_date_string} 00:00:00", '%m/%d/%Y %H:%M:%S')
      @to_date = DateTime.strptime("#{@to_date_string} 23:59:59", '%m/%d/%Y %H:%M:%S')

      @properties = []

      if @multiproperty
        property_tag = Tag.find_by_name("property")
        ((property_tag.extra_fields["ordering"] || "") rescue "").split(",").each do |ordered_property_name|
          @properties << ordered_property_name
        end
        TagsTag.where(:other_tag_id => property_tag.id).pluck(:tag_id).each do |tag_id|
          tag_name = Tag.find(tag_id).name
          @properties << tag_name unless @properties.include?(tag_name)
        end
      end

      counters_hashes = get_counters_hashes(@from_date, @to_date, @properties)
      @values = counters_hashes[0]
      @extra_fields = counters_hashes[1]

      flash[:notice] = 
        @values["migration_day"] == true ? 
          "Hai selezionato un periodo che comprende o precede il giorno di migrazione,
            dunque i dati visualizzati comprendono anche tutte le statistiche precedenti a quel giorno"
        : nil

      from = @from_date
      to = @to_date

      hash_total_users = get_hash_total_users()
      hash_social_reg_users = get_hash_social_reg_users()

      @days = (to - from).to_i
      days_interval = @days > 30 ? (@days / 30.0).round : 1
      @user_week_list = build_line_chart_values(from, to, hash_total_users, hash_social_reg_users, days_interval)

      # Cross-property values
      @total_users = @values["total-users"]
      @social_reg_users = @values["social-reg-users"]
      @total_rewards = @values["rewards"]
      @total_comments = @values["total-comments"]
      @approved_comments = @values["approved-comments"]

      # Property values
      if !params[:commit]
        if @multiproperty
          @property_tag_name = @properties.first.gsub("-", " ").split.map(&:capitalize).join(" ")
          @property_values = @values[@properties.first] || {}
        else
          @property_values = @values["general"]
        end
      elsif params[:commit] == "APPLICA FILTRO"
        if @multiproperty
          @property_tag_name = params[:property] || @properties.first.gsub("-", " ").split.map(&:capitalize).join(" ")
          @property_values = @property_values || @values[@properties.first]
        else
          @property_values = @property_values || @values["general"]
        end
      else # property selected
        @property_tag_name = params[:commit].downcase.split.map(&:capitalize).join(" ") || ""
        @property_values = @values[params[:commit].downcase] || {}
      end

    end
  end

  def get_counters_hashes(from_date, to_date, properties)
    first_user_reward = UserReward.where("period_id IS NOT NULL").minimum(:created_at) || UserReward.minimum(:created_at)
    if first_user_reward
      migration_date = first_user_reward.to_date
      counter_values_hash = {}
      if to_date > migration_date
        from_date = migration_date if from_date < migration_date && $site.id == "disney"
        EasyadminStats.where("date >= '#{from_date}' AND date <= '#{to_date}'").each_with_index do |stats, i|
          next_values_hash = stats.values
          counter_values_hash = i == 0 ? next_values_hash : sum_hashes_values(counter_values_hash, next_values_hash)
        end
      else
        counter_values_hash = EasyadminStats.find_by_date(migration_date).values
      end
      counter_names = get_keys_with_simple_value(counter_values_hash)
      counter_extra_fields_hash = {}
      Reward.where(:name => counter_names).each do |r|
        counter_extra_fields_hash[r.name] = r.extra_fields
      end
      # For levels and badges total count
      levels_extra_fields = Tag.find_by_name("level").extra_fields || {}
      badges_extra_fields = Tag.find_by_name("badge").extra_fields || {}
      if properties.any?
        properties.each do |property|
          assigned_prefix = property == $site.default_property ? "" : "#{property}-"
          counter_extra_fields_hash["#{assigned_prefix}assigned-levels"] = levels_extra_fields
          counter_extra_fields_hash["#{assigned_prefix}assigned-badges"] = badges_extra_fields
        end
      else
        counter_extra_fields_hash["assigned-levels"] = levels_extra_fields
        counter_extra_fields_hash["assigned-badges"] = badges_extra_fields
      end

      return counter_values_hash, counter_extra_fields_hash
    else
      return {}, {}
    end
  end

  def build_line_chart_values(from, to, hash_total_users, hash_social_reg_users, days_interval)
    user_week_list = {}
    starting_date = from
    total_users = 0
    social_reg_users = 0

    while from < to - 1.day do
      from_date = from.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d")
      total_users += (hash_total_users[from_date] || 0).to_i
      social_reg_users += (hash_social_reg_users[from_date] || 0).to_i
      if (from - starting_date).to_i % days_interval == 0
        user_week_list["#{from_date}"] = { "tot" => total_users, "simple" => social_reg_users }
      end
      from = from + 1.day
    end

    from_date = from.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d")
    to_date = to.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d")
    total_users += (hash_total_users[to_date] || 0).to_i
    social_reg_users += (hash_social_reg_users[to_date] || 0).to_i
    user_week_list["#{from_date}"] = { "tot" => total_users, "simple" => social_reg_users }

    user_week_list
  end

  def get_hash_total_users
    cache_huge(get_total_users_until_date_cache_key(Date.today)) do
      hash_total_users = {}
      User
        .select(["COUNT(*) AS total_users", "to_char(created_at, 'YYYY-MM-DD') AS date"])
        .where("anonymous_id IS NULL")
        .group("to_char(created_at, 'YYYY-MM-DD')")
        .each do |values| 
          hash_total_users[values.date] = values.total_users
        end
      hash_total_users
    end
  end

  def get_hash_social_reg_users
    cache_huge(get_social_reg_users_until_date_cache_key(Date.today)) do
      hash_social_reg_users = {}
      User
        .select(["COUNT(users.id) AS social_reg_users", "to_char(users.created_at, 'YYYY-MM-DD') AS date"])
        .joins("LEFT OUTER JOIN authentications ON authentications.user_id = users.id")
        .where("anonymous_id IS NULL AND authentications.user_id IS NULL")
        .group("to_char(users.created_at, 'YYYY-MM-DD')")
        .each do |values|
          hash_social_reg_users[values.date] = values.social_reg_users
        end
      hash_social_reg_users
    end
  end

  def index_most_clicked_interactions

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @call_to_actions = ViewCounter.where(:ref_type => "cta").order("counter DESC").page(page).per(per_page)

    @page_size = @call_to_actions.num_pages
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

  def get_current_month_event
    month_calltoaction_list = CallToAction.select("activated_at, id, title").where("activated_at<? AND activated_at>=?", (Time.parse(params["time"]).to_date + 2.month).change(day: 1).strftime("%Y/%m/%d"), (Time.parse(params["time"]).to_date - 1.month).change(day: 1).strftime("%Y/%m/%d"))
    respond_to do |format|
      format.json { render :json => month_calltoaction_list.to_json }
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