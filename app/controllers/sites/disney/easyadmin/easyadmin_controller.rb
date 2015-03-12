class Sites::Disney::Easyadmin::EasyadminController < Easyadmin::EasyadminController
  include EasyadminHelper
  include DateMethods

  def dashboard
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
      @social_reg_users = User.where(:created_at => @from_date..@to_date).includes(:authentications).where("authentications.user_id IS NOT NULL").count
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

      if params[:commit] == "VIOLETTA"
        @property_tag_name = "violetta"
        @property_prefix = "violetta-"
      else
        @property_tag_name = "disney-channel"
        @property_prefix = ""
      end

      # TOTAL USER REWARDS
      level_tag_id = Tag.find_by_name('level').id
      badge_tag_id = Tag.find_by_name('badge').id

      level_reward_ids = Array.new
      badge_reward_ids = Array.new
      RewardTag.find(:all, :conditions => ["tag_id = #{level_tag_id}"]).each do |rt|
        level_reward_ids << rt.reward_id
      end
      RewardTag.find(:all, :conditions => ["tag_id = #{badge_tag_id}"]).each do |rt|
        badge_reward_ids << rt.reward_id
      end

      total_level_or_badge_rewards_where_condition = ""
      (level_reward_ids | badge_reward_ids).each_with_index do |reward_id, i|
        connector = (i != (level_reward_ids | badge_reward_ids).length - 1) ? " or " : " "
        total_level_or_badge_rewards_where_condition << "reward_id = #{reward_id}#{connector}"
      end

      @total_rewards = UserReward.where("(#{total_level_or_badge_rewards_where_condition}) and period_id is null").count

      # COMMENTS
      @total_comments = UserCommentInteraction.where("created_at >= '#{@from_date}' and created_at <= '#{@to_date}'").count
      @approved_comments = UserCommentInteraction.where("approved = true and created_at >= '#{@from_date}' and created_at <= '#{@to_date}'").count
      # QUIZZES
      @property_trivia_answers = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}trivia-counter", @from_date, @to_date)
      @property_trivia_correct_answers = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}trivia-correct-counter", @from_date, @to_date)
      # VERSUS
      @property_versus_answers = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}versus-counter", @from_date, @to_date)
      # PLAYS
      @property_plays = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}play-counter", @from_date, @to_date)
      # LIKES
      @property_likes = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}like-counter", @from_date, @to_date)
      # CHECKS
      @property_checks = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}check-counter", @from_date, @to_date)
      # SHARES
      @property_shares = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}share-counter", @from_date, @to_date)
      # DOWNLOADS
      @property_downloads = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}download-counter", @from_date, @to_date)
      # VOTES
      @property_votes = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}vote-counter", @from_date, @to_date)
      # ASSIGNED LEVELS AND BADGES
      property_reward_ids = Array.new
      property_tag_id = Tag.find_by_name(@property_tag_name).id
      RewardTag.find(:all, :conditions => ["tag_id = #{property_tag_id}"]).each do |rt|
        property_reward_ids << rt.reward_id
      end

      property_level_reward_ids = property_reward_ids & level_reward_ids
      property_badge_reward_ids = property_reward_ids & badge_reward_ids

      @property_assigned_levels = UserReward.where("reward_id in (#{property_level_reward_ids.to_s[1..-2]}) and period_id is null").count
      @property_assigned_badges = UserReward.where("reward_id in (#{property_badge_reward_ids.to_s[1..-2]}) and period_id is null").count

    end
  end

  def find_user_reward_count_by_reward_name_at_date(reward_name, from_date, to_date)
    reward_id = Reward.find_by_name(reward_name).id
    where_condition = "reward_id = #{reward_id} and period_id is null"
    UserReward.where(where_condition).pluck("sum(counter)").first.to_i
  end
end