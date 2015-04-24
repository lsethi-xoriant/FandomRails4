class Sites::Disney::Easyadmin::EasyadminController < Easyadmin::EasyadminController
  include EasyadminHelper
  include DateMethods

  def dashboard
    authorize! :access, :dashboard

    if User.any? 
      if (params[:datepicker_from_date].blank? || params[:commit] == "Reset") 
        @from_date_string = (Time.now - 1.week).strftime('%m/%d/%Y')
      else
        @from_date_string = params[:datepicker_from_date]
      end
      @to_date_string = (params[:datepicker_to_date].blank? || params[:commit] == "Reset") ? 
                          Time.now.strftime('%m/%d/%Y')
                            : params[:datepicker_to_date]

      @from_date = datetime_parsed_to_utc(DateTime.strptime("#{@from_date_string} 00:00:00 #{USER_TIME_ZONE_ABBREVIATION}", '%m/%d/%Y %H:%M:%S %z'))
      @to_date = datetime_parsed_to_utc(DateTime.strptime("#{@to_date_string} 23:59:59 #{USER_TIME_ZONE_ABBREVIATION}", '%m/%d/%Y %H:%M:%S %z'))

      # @properties = Setting.find_by_key(PROPERTIES_LIST_KEY).value.split(',')
      @properties = []
      property_tag = Tag.find_by_name("property")
      (JSON.parse(property_tag.extra_fields)["ordering"] rescue "").split(",").each do |ordered_property_name|
        @properties << ordered_property_name
      end
      TagsTag.where(:other_tag_id => property_tag.id).pluck(:tag_id).each do |tag_id|
        tag_name = Tag.find(tag_id).name
        @properties << tag_name unless @properties.include?(tag_name)
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

      @total_users = @values["total-users"]
      @social_reg_users = @values["social-reg-users"]

      if !params[:commit]
        @property_tag_name = @properties.first.gsub("-", " ").split.map(&:capitalize).join(" ")
        @property_values = @values[@properties.first] || {}
      elsif params[:commit] == "APPLICA FILTRO"
        @property_tag_name = params[:property] || @properties.first.gsub("-", " ").split.map(&:capitalize).join(" ")
        @property_values = @property_values || @values[@properties.first]
      else
        @property_tag_name = params[:commit].downcase.split.map(&:capitalize).join(" ") || ""
        @property_values = @values[params[:commit].downcase] || {}
      end

      # REWARDS
      @total_rewards = @values["rewards"]
      # COMMENTS
      @total_comments = @values["total-comments"]
      @approved_comments = @values["approved-comments"]
      # # QUIZZES
      # @property_trivia_answers = @property_values["trivia_answers"]
      # @property_trivia_correct_answers = @property_values["trivia_correct_answers"]
      # # VERSUS
      # @property_versus_answers = @property_values["versus_answers"]
      # # PLAYS
      # @property_plays = @property_values["plays"]
      # # LIKES
      # @property_likes = @property_values["likes"]
      # # CHECKS
      # @property_checks = @property_values["checks"]
      # # SHARES
      # @property_shares = @property_values["shares"]
      # # DOWNLOADS
      # @property_downloads = @property_values["downloads"]
      # # VOTES
      # @property_votes = @property_values["votes"]
      # # LEVELS AND BADGES
      # @property_assigned_levels = @property_values["assigned_levels"]
      # @property_assigned_badges = @property_values["assigned_badges"]
    end
  end

  def get_counters_hashes(from_date, to_date, properties)
    migration_date = UserReward.where("period_id IS NOT NULL").minimum(:created_at).to_date
    counter_values_hash = {}
    if to_date > migration_date
      from_date = migration_date if from_date < migration_date
      EasyadminStats.where("date >= '#{from_date}' AND date <= '#{to_date}'").each_with_index do |stats, i|
        next_values_hash = JSON.parse(stats.values)
        counter_values_hash = i == 0 ? next_values_hash : sum_hashes_values(counter_values_hash, next_values_hash)
      end
    else
      counter_values_hash = JSON.parse(EasyadminStats.find_by_date(migration_date).values)
    end
    counter_names = get_keys_with_simple_value(counter_values_hash)
    counter_extra_fields_hash = {}
    Reward.where(:name => counter_names).each do |r|
      counter_extra_fields_hash[r.name] = JSON.parse(r.extra_fields)
    end
    # for levels and badges total count
    levels_extra_fields = JSON.parse(Tag.find_by_name("level").extra_fields) rescue {}
    badges_extra_fields = JSON.parse(Tag.find_by_name("badges").extra_fields) rescue {}
    properties.each do |property|
      assigned_prefix = property == "disney-channel" ? "" : "#{property}-"
      counter_extra_fields_hash["#{assigned_prefix}assigned-levels"] = levels_extra_fields
      counter_extra_fields_hash["#{assigned_prefix}assigned-badges"] = badges_extra_fields
    end

    return counter_values_hash, counter_extra_fields_hash
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
        user_week_list["#{ from_date }"] = { "tot" => total_users, "simple" => social_reg_users }
      end
      from = from + 1.day
    end

    from_date = from.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d")
    to_date = to.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d")
    total_users += (hash_total_users[to_date] || 0).to_i
    social_reg_users += (hash_social_reg_users[to_date] || 0).to_i
    user_week_list["#{ from_date }"] = { "tot" => total_users, "simple" => social_reg_users }

    user_week_list
  end

  # Public: Recursive method to sum integer values of same structured hashes.
  # More precisely, second hash keys have to be a subset of first's.
  #
  # Examples
  # 
  #    sum_hashes_values({ "eggs" => 2, "chocolate_bars" => 1 }, { "eggs" => 3, "chocolate_bars" => 3 })
  #    # => { "eggs" => 5, "chocolate_bars => 4" }
  #
  #    sum_hashes_values({ "pears" => 2, "apples" => { "red" => 1, "yellow" => 2 }, "bananas" => 4 }, 
  #                      { "pears" => 3, "apples" => { "red" => 3, "yellow" => 2 } })
  #    # => { "pears" => 5, "apples" => { "red" => 4, "yellow" => 4 }, "bananas" => 4 }
  #
  # Returns the summed values hash
  def sum_hashes_values(hash_1, hash_2)
    hash_1.merge(hash_2) do |k, value_1, value_2|
      if value_1.class == Hash
        sum_hashes_values(value_1, value_2)
      else
        value_1 + value_2
      end
    end
  end

  # Public: Recursive method to collect every Hash key with referring to a non-Hash value 
  #
  # Examples
  # 
  #    get_keys_with_simple_value({ "water" => 1, "red_wines" => { "cabernet" => 5, "merlot" => 2 }, "white_wines" => { "chardonnay" => 3, "moscato" => 4 } })
  #    # => ["water", "cabernet", "merlot", "chardonnay", "moscato"]
  #
  # Returns the keys array
  def get_keys_with_simple_value(hash)
    res = []
    hash.each do |key, value|
      if value.class == Hash
        res += get_keys_with_simple_value(value)
      else
        res << key
      end
    end
    res
  end

  def get_hash_total_users
    cache_huge(get_total_users_until_date_cache_key(Date.today)) do
      hash_total_users = {}
      User
        .select(["COUNT(*) AS total_users", "to_char(created_at, 'YYYY-MM-DD') AS date"])
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
        .joins("LEFT OUTER JOIN disney.authentications ON authentications.user_id = users.id")
        .where("authentications.user_id IS NULL")
        .group("to_char(users.created_at, 'YYYY-MM-DD')")
        .each do |values|
          hash_social_reg_users[values.date] = values.social_reg_users
        end
      hash_social_reg_users
    end
  end

end