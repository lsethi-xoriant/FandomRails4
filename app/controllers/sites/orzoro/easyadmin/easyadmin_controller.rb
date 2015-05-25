class Sites::Orzoro::Easyadmin::EasyadminController < Easyadmin::EasyadminController
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

      @total_users = User.where(:created_at => @from_date..@to_date).count
      @social_reg_users = User.where(:created_at => @from_date..@to_date).includes(:authentications).where("authentications.user_id IS NOT NULL").references(:authentications).count
      from = @from_date
      to = @to_date

      if((to - from).to_i <= 7 && params[:time_interval] != "daily")
        params[:time_interval] = "daily"
      end

      while from < to - 1.day do 
        @user_week_list["#{from.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d") }"] = {
          "tot" => User.where("created_at<=?", from).count,
          "simple" => User.includes(:authentications).where("authentications.user_id IS NULL AND users.created_at<=?", from).references(:authentications).count
          }
        from = (params[:time_interval] == "daily" && params[:commit] != "Reset") ? from + 1.day : from + 1.week
      end
      @user_week_list["#{from.in_time_zone(USER_TIME_ZONE_ABBREVIATION).strftime("%Y-%m-%d") }"] = {
          "tot" => User.where("created_at<=?", to).count,
          "simple" => User.includes(:authentications).where("authentications.user_id IS NULL AND users.created_at<=?", to).references(:authentications).count
          }

      period_ids = get_period_ids(@from_date, @to_date)

      # CUP REQUESTS
      @cup_requests = find_user_reward_count_by_reward_name_at_date("cup-redeem-counter", period_ids)
      # TESTS
      @tests = find_user_reward_count_by_reward_name_at_date("test-counter", period_ids)
      # LINKS
      @links = find_user_reward_count_by_reward_name_at_date("link-counter", period_ids)
      # PLAYS
      @plays = find_user_reward_count_by_reward_name_at_date("play-counter", period_ids)
      # DOWNLOADS
      @downloads = find_user_reward_count_by_reward_name_at_date("download-counter", period_ids)
      # SHARES
      @shares = find_user_reward_count_by_reward_name_at_date("share-counter", period_ids)

    end
  end

end