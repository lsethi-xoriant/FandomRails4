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
      RewardTag.find(:all, :conditions => ["tag_id = #{level_tag_id}"]) do |rt|
        level_reward_ids << rt.id
      end
      RewardTag.find(:all, :conditions => ["tag_id = #{badge_tag_id}"]) do |rt|
        badge_reward_ids << rt.id
      end

      total_level_or_badge_rewards_where_condition = ""
      (level_reward_ids | badge_reward_ids).each_with_index do |reward_id, i|
        connector = (i != (level_reward_ids | badge_reward_ids).length - 1) ? " or " : " "
        total_level_or_badge_rewards_where_condition << "reward_id = #{reward_id}#{connector}"
      end

      @total_rewards_to_date = UserReward.where("(#{total_level_or_badge_rewards_where_condition}) and created_at <= '#{@to_date}'").count
      @total_rewards_from_date = UserReward.where("(#{total_level_or_badge_rewards_where_condition}) and created_at <= '#{@from_date}'").count

      # COMMENTS
      @total_comments_to_date = UserCommentInteraction.where("created_at <= '#{@to_date}'").count
      @total_comments_from_date = UserCommentInteraction.where("created_at <= '#{@from_date}'").count

      # QUIZZES
      @property_trivia_answers_to_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}trivia-counter", @to_date)
      @property_trivia_answers_from_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}trivia-counter", @from_date)
      @property_trivia_correct_answers_to_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}trivia-correct-counter", @to_date)
      @property_trivia_correct_answers_from_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}trivia-correct-counter", @from_date)

      # VERSUS
      @property_versus_answers_to_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}versus-counter", @to_date)
      @property_versus_answers_from_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}versus-counter", @from_date)

      # PLAYS
      @property_plays_to_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}play-counter", @to_date)
      @property_plays_from_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}play-counter", @from_date)

      # LIKES
      @property_likes_to_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}like-counter", @to_date)
      @property_likes_from_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}like-counter", @from_date)

      # CHECKS
      @property_checks_to_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}check-counter", @to_date)
      @property_checks_from_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}check-counter", @from_date)

      # SHARES
      @property_shares_to_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}share-counter", @to_date)
      @property_shares_from_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}share-counter", @from_date)

      # DOWNLOADS
      @property_downloads_to_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}download-counter", @to_date)
      @property_downloads_from_date = find_user_reward_count_by_reward_name_at_date("#{@property_prefix}download-counter", @from_date)

      # ASSIGNED LEVELS AND BADGES
      property_reward_ids = Array.new
      RewardTag.find(:all, :conditions => ["tag_id = #{@property_tag_name}"]) do |rt|
        property_reward_ids << rt.id
      end

      property_level_reward_ids = property_reward_ids & level_reward_ids
      property_badge_reward_ids = property_reward_ids & badge_reward_ids

      @property_assigned_levels_to_date = UserReward.where("reward_id = #{property_level_reward_ids.to_s[1..-2]} and created_at <= '#{@to_date}'").count
      @property_assigned_levels_from_date = UserReward.where("reward_id = #{property_level_reward_ids.to_s[1..-2]} and created_at <= '#{@from_date}'").count
      @property_assigned_badges_to_date = UserReward.where("reward_id = #{property_badge_reward_ids.to_s[1..-2]} and created_at <= '#{@to_date}'").count
      @property_assigned_badges_from_date = UserReward.where("reward_id = #{property_badge_reward_ids.to_s[1..-2]} and created_at <= '#{@from_date}'").count

    end
  end

  def find_user_reward_count_by_reward_name_at_date(reward_name, date)
    reward_id = Reward.find_by_name(reward_name).id
    UserReward.where("reward_id = #{reward_id} and created_at <= '#{date}'").count
  end
end