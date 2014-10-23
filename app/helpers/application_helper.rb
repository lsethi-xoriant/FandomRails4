#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

module ApplicationHelper
  include CacheHelper
  include RewardingSystemHelper
  include NoticeHelper
  
  class BrowseCategory
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults

    # human readable name of this field
    attribute :title, type: String
    # html id of this field
    attribute :id, type: String
    attribute :has_thumb, type: Boolean
    attribute :thumb_url, type: String
    attribute :description, type: String
    attribute :long_description, type: String
    attribute :detail_url, type: String
    attribute :created_at, type: Integer
    attribute :header_image_url, type: String
    attribute :icon_url, type: String
  end

  class ContentSection
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    # key can be either tag name or special keyword such as $recent
    attribute :key, type: String
    attribute :title, type: String
    attribute :contents
    attribute :view_all_link, type: String
    attribute :column_number, type: Integer
  end

  def order_highlight_calltoactions_by_ordering_meta(meta_ordering, highlight_calltoactions)
    ordered_highlight_calltoaction_names = meta_ordering.value.split(",")
    if ordered_highlight_calltoaction_names.any?         
      ordered_highlight_calltoactions = Array.new
      ordered_highlight_calltoaction_names.each do |calltoaction_name|
        highlight_calltoactions.each do |calltoaction|
          if calltoaction.name == calltoaction_name
            ordered_highlight_calltoactions << calltoaction
          end
        end
      end
      highlight_calltoactions.each do |calltoaction|
        unless ordered_highlight_calltoaction_names.include?(calltoaction.name) 
          ordered_highlight_calltoactions << calltoaction
        end
      end
      ordered_highlight_calltoactions
    else
      highlight_calltoactions
    end
  end

  def get_highlight_calltoactions()
    tag = Tag.find_by_name("highlight")
    if tag
      highlight_calltoactions = calltoaction_active_with_tag(tag.name, "DESC")
      meta_ordering = tag.tag_fields.find_by_name("ordering")    
      if meta_ordering
        ordered_highlight_calltoactions = order_highlight_calltoactions_by_ordering_meta(meta_ordering, highlight_calltoactions)
      else
        highlight_calltoactions
      end
    else
      []
    end
  end

  def cached_nil?(cached_value)
    cached_value.class == CachedNil
  end

  def ga_code
    begin
      ga = Rails.configuration.deploy_settings["sites"][get_site_from_request(request)["id"]]["ga"]
    rescue Exception => exception
    end
    ga
  end

  def merge_aux(aux_1, aux_2)

    begin
      aux_1 = JSON.parse(aux_1)
      aux_2 = JSON.parse(aux_2)

      aux_2.each do |key, value|
        if aux_1[key].present?
          aux_1[key] = aux_1[key] + value
        else
          aux_1[key] = value
        end
      end
    rescue Exception => exception
      return nil
    end

    aux_1.present? ? aux_1.to_json : nil

  end

  def create_or_update_interaction(user, interaction, answer_id, like, aux = "{}")
    user_interaction = user.user_interactions.find_by_interaction_id(interaction.id)

    if user_interaction
      if interaction.resource_type.downcase == "share"
        aux = merge_aux(aux, user_interaction.aux)
      end

      user_interaction.assign_attributes(counter: (user_interaction.counter + 1), answer_id: answer_id, like: like, aux: aux)
      UserCounter.update_counters(interaction, user_interaction, user, false) 
    else
      user_interaction = UserInteraction.new(user_id: user.id, interaction_id: interaction.id, answer_id: answer_id, like: like, aux: aux)
      UserCounter.update_counters(interaction, user_interaction, user, true)

      expire_cache_key(get_cta_completed_or_reward_status_cache_key(interaction.call_to_action_id, user.id))
    end

    outcome = compute_save_and_notify_outcome(user_interaction)
    outcome.info = []
    outcome.errors = []
    
    if user_interaction.outcome.present?
      interaction_outcome = Outcome.new(JSON.parse(user_interaction.outcome)["win"])
      interaction_outcome.merge!(outcome)
    else
      interaction_outcome = outcome
    end

    outcome_for_user_interaction = { win: interaction_outcome }

    is_trivia_interaction = interaction.resource_type.downcase == "quiz" && interaction.resource.quiz_type.downcase == "trivia"
    if is_trivia_interaction
      predict_outcome_with_correct_answer = predict_outcome(interaction, user, true)
      if user_interaction.outcome.present?
        interaction_correct_answer_outcome = Outcome.new(JSON.parse(user_interaction.outcome)["correct_answer"])
        interaction_correct_answer_outcome.merge!(predict_outcome_with_correct_answer)
      else
        interaction_correct_answer_outcome = predict_outcome_with_correct_answer
      end
      outcome_for_user_interaction[:correct_answer] = interaction_correct_answer_outcome
    end

    user_interaction.assign_attributes(outcome: outcome_for_user_interaction.to_json)
    user_interaction.save
  
    [user_interaction, outcome]
  
  end
  
  def interaction_done?(interaction)
    return current_user && UserInteraction.find_by_user_id_and_interaction_id(current_user.id, interaction.id)
  end

  def get_tag_to_rewards()
    cache_short("tag_to_rewards") do
      tag_to_rewards = Hash.new
      RewardTag.all.each do |reward_tag|
        unless tag_to_rewards.key? reward_tag.tag.name
          tag_to_rewards[reward_tag.tag.name] = Set.new 
        end
        tag_to_rewards[reward_tag.tag.name] << reward_tag.reward 
      end
      tag_to_rewards
    end
  end

  def get_tag_with_tag_about_call_to_action(calltoaction, tag_name)
    cache_short get_tag_with_tag_about_call_to_action_cache_key(calltoaction.id, tag_name) do
      Tag.includes(tags_tags: :other_tag).includes(:call_to_action_tags).includes(:tag_fields).where("other_tags_tags_tags.name = ? AND call_to_action_tags.call_to_action_id = ?", tag_name, calltoaction.id).to_a
    end
  end

  def get_tags_with_tag(tag_name)
    cache_short get_tags_with_tag_cache_key(tag_name) do
      Tag.includes(:tags_tags => :other_tag ).includes(:tag_fields).where("other_tags_tags_tags.name = ?", tag_name).to_a
    end
  end
  
  def get_ctas_with_tag(tag_name)
    cache_short get_ctas_with_tag_cache_key(tag_name) do
      CallToAction.active.includes(call_to_action_tags: :tag).where("tags.name = ?", tag_name).to_a
    end
  end
  
  def get_all_ctas_with_tag(tag_name)
    cache_short get_ctas_with_tag_cache_key(tag_name) do
      CallToAction.includes(call_to_action_tags: :tag).where("tags.name = ?", tag_name).to_a
    end
  end
  
  def get_rewards_with_tag(tag_name)
    cache_short get_rewards_with_tag_cache_key(tag_name) do
      Reward.includes(reward_tags: :tag).where("tags.name = ?", tag_name).to_a
    end
  end
  
  def get_tags_for_vote_ranking(vote_ranking)
    tags = vote_ranking.vote_ranking_tags
    taglist = Array.new
    tags.each do |t|
      taglist << t.tag.name
    end
    taglist.join(",")
  end
  
  def get_user_interaction_from_interaction(interaction, user)
    user.user_interactions.find_by_interaction_id(interaction.id)
  end

  def push_in_array(array, element, push_times)
    push_times.times do
      array << element
    end
  end

  def call_to_action_completed?(cta)
    if current_user
      require_to_complete_interactions = interactions_required_to_complete(cta)
      require_to_complete_interactions_ids = require_to_complete_interactions.map { |i| i.id }
      interactions_done = UserInteraction.where("user_interactions.user_id = ? and interaction_id IN (?)", current_user.id, require_to_complete_interactions_ids)
      require_to_complete_interactions.any? && (require_to_complete_interactions.count == interactions_done.count)
    else
      false
    end
  end

  def compute_call_to_action_completed_or_reward_status(reward_name, calltoaction)
    call_to_action_completed_or_reward_status = cache_short get_cta_completed_or_reward_status_cache_key(calltoaction.id, current_or_anonymous_user.id) do
      if call_to_action_completed?(calltoaction)
        CACHED_NIL
      else
        compute_current_call_to_action_reward_status(reward_name, calltoaction)
      end
    end

    if !cached_nil?(call_to_action_completed_or_reward_status)
      JSON.parse(call_to_action_completed_or_reward_status)
    else 
      nil
    end
  end

  # Generates an hash with reward information.
  def compute_current_call_to_action_reward_status(reward_name, calltoaction)
    reward = get_reward_from_cache(reward_name)
    
    winnable_outcome, interaction_outcomes, sorted_interactions = predict_max_cta_outcome(calltoaction, current_user)
    
    interaction_outcomes_and_interaction = interaction_outcomes.zip(sorted_interactions)

    reward_status_images = Array.new
    total_win_reward_count = 0

    if current_user

      interaction_outcomes_and_interaction.each do |intearction_outcome, interaction|
        user_interaction = interaction.user_interactions.find_by_user_id(current_user.id)        
  
        if user_interaction && user_interaction.outcome.present?
          win_reward_count = JSON.parse(user_interaction.outcome)["win"]["attributes"]["reward_name_to_counter"].fetch(reward_name, 0)
          correct_answer_outcome = JSON.parse(user_interaction.outcome)["correct_answer"]
          correct_answer_reward_count = correct_answer_outcome ? correct_answer_outcome["attributes"]["reward_name_to_counter"].fetch(reward_name, 0) : 0

          total_win_reward_count += win_reward_count;

          push_in_array(reward_status_images, reward.preview_image(:thumb), win_reward_count)
          push_in_array(reward_status_images, reward.not_winnable_image(:thumb), correct_answer_reward_count - win_reward_count)
          push_in_array(reward_status_images, reward.not_awarded_image(:thumb), intearction_outcome["reward_name_to_counter"][reward_name])
        else 
          push_in_array(reward_status_images, reward.not_awarded_image(:thumb), intearction_outcome["reward_name_to_counter"][reward_name])
        end       

      end

    else
      push_in_array(reward_status_images, reward.not_awarded_image(:thumb), winnable_outcome["reward_name_to_counter"][reward_name])
    end

    {
      winnable_reward_count: winnable_outcome["reward_name_to_counter"][reward_name],
      win_reward_count: total_win_reward_count,
      reward_status_images: reward_status_images,
      reward: reward
    }.to_json
  end

  def get_current_interaction_reward_status(reward_name, interaction)
    reward = get_reward_by_name(reward_name)

    reward_status_images = Array.new 

    if current_user
      user_interaction = interaction.user_interactions.find_by_user_id(current_user.id)
    else
      user_interaction = nil
    end

    if user_interaction
      win_reward_count = JSON.parse(user_interaction.outcome)["win"]["attributes"]["reward_name_to_counter"].fetch(reward_name, 0)
      correct_answer_outcome = JSON.parse(user_interaction.outcome)["correct_answer"]
      correct_answer_reward_count = correct_answer_outcome ? correct_answer_outcome["attributes"]["reward_name_to_counter"].fetch(reward_name, 0) : 0

      winnable_reward_count = 0

      push_in_array(reward_status_images, reward.preview_image(:thumb), win_reward_count)
      push_in_array(reward_status_images, reward.not_winnable_image(:thumb), correct_answer_reward_count - win_reward_count)
    else
      win_reward_count = 0
      winnable_reward_count = predict_outcome(interaction, nil, true).reward_name_to_counter[reward_name]
      push_in_array(reward_status_images, reward.not_awarded_image(:thumb), winnable_reward_count)
    end

    {
      win_reward_count: win_reward_count,
      winnable_reward_count: winnable_reward_count,
      reward_status_images: reward_status_images,
      reward: reward
    }

  end

  def get_counter_about_user_reward(reward_name, all_periods = false)
    if current_user
      reward_points = cache_short(get_reward_points_for_user_key(reward_name, current_user.id)) do
        reward_points = Hash.new
        get_reward_with_periods(reward_name).each do |user_reward|
          if user_reward.period.blank?
            reward_points[:general] = user_reward.counter
          else
            reward_points[user_reward.period.kind] = user_reward.counter
          end
        end 
        reward_points     
      end
      all_periods ? reward_points : reward_points[:general]  
    else
      nil
    end
  end
  
  def get_reward_with_periods(reward_name)
    reward = Reward.find_by_name(reward_name)
    user_reward = UserReward.includes(:period)
      .where("user_rewards.reward_id = ? AND user_rewards.user_id = ?", reward.id, current_user.id)
      .where("periods.id IS NULL OR (periods.start_datetime < ? AND periods.end_datetime > ?)", Time.now.utc, Time.now.utc)
  end

  def user_has_reward(reward_name)
    current_or_anonymous_user.user_rewards.includes(:reward).where("rewards.name = '#{reward_name}'").any?
  end

  def compute_rewards_gotten_over_total(reward_ids)
    if reward_ids.any?
      place_holders = (["?"] * reward_ids.count).join ", "
      current_or_anonymous_user.user_rewards.where("reward_id IN (#{place_holders})", *reward_ids).count
    else
      0
    end
  end

  def interaction_answer_percentage(interaction, answer)
    cache_short("interaction_#{interaction.id}_answer_#{answer.id}_percentage") do
      interaction_answers_count = interaction.user_interactions.count
      
      if interaction_answers_count < 1
        nil
      else
        interaction_current_answer_count = interaction.user_interactions.where("answer_id = ?", answer.id).count
        ((interaction_current_answer_count.to_f / interaction_answers_count.to_f) * 100).round
      end
    end
  end

  def anonymous_user
    cache_medium('anonymous_user') { 
      User.find_by_email("anonymous@shado.tv")
    }
  end

  def current_or_anonymous_user
    if current_user.present? 
      current_user
    else
      anonymous_user
    end
  end
  
  def mobile_device?()
    FandomUtils::request_is_from_mobile_device?(request)
  end

  def small_mobile_devise?()
    FandomUtils::request_is_from_small_mobile_device?(request)
  end

  def ipad?
    return request.user_agent =~ /iPad/ 
  end

  def find_interaction_for_calltoaction_by_resource_type(calltoaction, resource_type)
    interactions = cache_short get_interaction_for_calltoaction_by_resource_type_cache_key(calltoaction.id, resource_type) do
      interactions = Interaction.where("resource_type = ? AND when_show_interaction <> 'MAI_VISIBILE' AND call_to_action_id = ?", resource_type, calltoaction.id)
    end
    interactions.any? ? interactions.first : nil
  end

  def calltoaction_active_with_tag(tag, order)
    return CallToAction.includes(:call_to_action_tags, call_to_action_tags: :tag).where("activated_at <= ? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NOT NULL AND tags.name = ?)", Time.now, tag).order("activated_at #{order}")
  end

  def calltoaction_coming_soon_with_tag(tag, order)
    return CallToAction.includes(:call_to_action_tags, call_to_action_tags: :tag).where("activated_at>? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NOT NULL AND tags.name=?)", Time.now, tag).order("activated_at #{order}")
  end 

  # Get calltoaction's share interactions.
  def share_interactions(calltoaction)
    calltoaction_share_interactions = cache_short("calltoaction_#{calltoaction.id}_share_interactions") do
      calltoaction.interactions.where("resource_type = ? AND when_show_interaction = ?", "Share", "SEMPRE_VISIBILE").to_a
    end
  end

  def extract_name_or_username(user)
    if user.first_name.blank? && user.last_name.blank?
      user.username
    else
      "#{user.first_name} #{user.last_name}"
    end
  end

  def current_avatar size = "normal"
    if current_user
      return user_avatar current_user
    else
      return "/assets/anon.png"
    end
  end

  def user_avatar user, size = "normal"
    user.avatar_selected_url.present? ? user.avatar_selected_url : "/assets/anon.png"
  end

  def disqus_sso
    if current_user && ENV['DISQUS_SECRET_KEY'] && ENV['DISQUS_PUBLIC_KEY']
      user = current_user
      data = {
          'id' => user.id,
          'username' => "#{ user.first_name } #{ user.last_name }",
          'email' => user.email,
        'avatar' =>  current_avatar
          # 'url' => user.url
      }.to_json
   
      message = Base64.encode64(data).gsub("\n", "") # Encode the data to base64.    
      timestamp = Time.now.to_i # Generate a timestamp for signing the message.
      sig = OpenSSL::HMAC.hexdigest('sha1', ENV['DISQUS_SECRET_KEY'], '%s %s' % [message, timestamp]) # Generate our HMAC signature
   
      x = 
        "<script type=\"text/javascript\">" +
          "var disqus_config = function() {" +
          "this.page.remote_auth_s3 = \"#{ message } #{ sig } #{ timestamp }\";" +
          "this.page.api_key = \"#{ ENV['DISQUS_PUBLIC_KEY'] }\";" +
          "this.sso = {" +
                  "name:   \"SampleNews\"," +
                  "button:  \"http://placehold.it/50x50\"," +
                  "icon:     \"http://placehold.it/50x50\"," +
                  "url:        \"http://example.com/login/\"," +
                  "logout:  \"http://example.com/logout/\"," +
                  "width:   \"800\"," +
                  "height:  \"400\"" +
            "};" +
          "}" +
        "</script>"
      
      return x
    else
      return "DISQUS debugger: user not logged or wrong keys."
    end
    end

  def calculate_month_string_ita(month_number)
      case month_number
        when 1
          return "gennaio"
        when 2
          return "febbraio"
        when 3
          return "marzo"
        when 4
          return "aprile"
        when 5
          return "maggio"
        when 6
          return "giugno"
        when 7
          return "luglio"
        when 8
          return "agosto"
        when 9
          return "settembre"
        when 10
          return "ottobre"
        when 11
          return "novembre"
        when 12
          return "dicembre"
        else
          return ""
      end
    end
  
  def get_to_be_notified_reward_names
    rewards = get_rewards_with_tag(TO_BE_NOTIFIED_REWARD_NAME)
    to_be_notified_rewards_names = Set.new
    rewards.each do |r|
      to_be_notified_rewards_names.add(r.name)
    end
    to_be_notified_rewards_names
  end
  
  def compute_save_and_notify_outcome(user_interaction)
    outcome = compute_and_save_outcome(user_interaction)
    to_be_notified_reward_names = get_to_be_notified_reward_names
    
    outcome.reward_name_to_counter.each do |r|
      reward_name = r.first
      if to_be_notified_reward_names.include?(reward_name)
        reward = get_reward_by_name(reward_name)
        html_notice = render_to_string "/easyadmin/easyadmin_notice/_notice_template", locals: { reward: reward }, layout: false, formats: :html
        notice = create_notice(:user_id => user_interaction.user_id, :html_notice => html_notice, :viewed => false, :read => false)
        # notice.send_to_user(request)
        expire_cache_key(notification_cache_key(user_interaction.user_id))
      end
    end
    
    outcome
  end
  
  def days_in_month(month, year = Time.now.year)
   return 29 if month == 2 && Date.gregorian_leap?(year)
   DAYS_IN_MONTH[month]
  end
  
  def get_pages(results, results_per_page)
    if results % results_per_page == 0
      results / results_per_page
    else
      results / results_per_page + 1
    end
  end

  # Trace the time spend by the block passed as parameter.
  # This function cannot be named just "trace" because of a conflict with rake db:migrate
  def trace_block(message, data, &block)
    start_time = Time.now.utc
    result = yield block
    time = Time.now.utc - start_time
    data['time'] = time
    log_debug(message, data)
    result 
  end

  def get_main_reward
    cache_short("main_reward") do
      Reward.find_by_name(MAIN_REWARD_NAME);
    end
  end

  def get_reward_by_name(reward_name)
    cache_short("reward_#{reward_name}") do
      Reward.find_by_name(reward_name)
    end
  end
  
  def get_main_reward_image_url
    cache_short("main_reward_image") do
      Reward.find_by_name(MAIN_REWARD_NAME).main_image.url
    end
  end
  
  def get_cta_button_label(cta)
    if cta.aux && JSON.parse(cta.aux)['button_label'] && !JSON.parse(cta.aux)['button_label'].blank?
      JSON.parse(cta.aux)['button_label']
    else
      CTA_DEFAULT_BUTTON_LABEL
    end
  end
  
end
