class Sites::Disney::Easyadmin::EasyadminController < Easyadmin::EasyadminController
  include EasyadminHelper
  include DateMethods

  def dashboard
    authorize! :access, :dashboard

    @user_week_list = Hash.new
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

      @values = fill_values_hash(@from_date, @to_date)

      flash[:notice] = @values["migration_day"] == true ? 
                        "Hai selezionato un periodo che comprende o precede il giorno di migrazione,
                          dunque i dati visualizzati comprendono tutte le statistiche precedenti a quel giorno"
                        : nil

      @total_users = @values["total_users"]
      @social_reg_users = @values["social_reg_users"]
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

      @properties = Setting.find_by_key(PROPERTIES_LIST_KEY).value.split(',')

      if params[:commit] == "APPLICA FILTRO"
        @property_tag_name = params[:property] || "Disney Channel"
        @property_values = @property_values || @values["disney_channel"]
      elsif (params[:commit] == "DISNEY-CHANNEL") || (params[:commit].nil?)
        @property_tag_name = "Disney Channel"
        @property_values = @values["disney_channel"] || {}
      else
        @property_tag_name = "Violetta"
        @property_values = @values["violetta"] || {}
      end

      # REWARDS
      @total_rewards = @values["rewards"]
      # COMMENTS
      @total_comments = @values["total_comments"]
      @approved_comments = @values["approved_comments"]
      # QUIZZES
      @property_trivia_answers = @property_values["trivia_answers"]
      @property_trivia_correct_answers = @property_values["trivia_correct_answers"]
      # VERSUS
      @property_versus_answers = @property_values["versus_answers"]
      # PLAYS
      @property_plays = @property_values["plays"]
      # LIKES
      @property_likes = @property_values["likes"]
      # CHECKS
      @property_checks = @property_values["checks"]
      # SHARES
      @property_shares = @property_values["shares"]
      # DOWNLOADS
      @property_downloads = @property_values["downloads"]
      # VOTES
      @property_votes = @property_values["votes"]
      # LEVELS AND BADGES
      @property_assigned_levels = @property_values["assigned_levels"]
      @property_assigned_badges = @property_values["assigned_badges"]
    end
  end

  def fill_values_hash(from_date, to_date)
    migration_date = UserReward.where("period_id IS NOT NULL").minimum(:created_at).to_date
    values = {}
    if to_date > migration_date
      if from_date < migration_date
        from_date = migration_date 
      end
      EasyadminStats.where("date >= '#{from_date}' AND date <= '#{to_date}'").each_with_index do |stats, i|
        next_values_hash = JSON.parse(stats.values)
        if i == 0
          values = next_values_hash
        else
          values = sum_hashes_values(values, next_values_hash)
        end
      end
    else
      values = JSON.parse(EasyadminStats.find_by_date(migration_date).values)
    end
    return values
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

end