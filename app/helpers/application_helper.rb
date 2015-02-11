#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

module ApplicationHelper
  include CacheHelper
  include RewardingSystemHelper
  include NoticeHelper
  include BrowseHelper
  include LogHelper

  class ContentSection
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    # key can be either tag name or special keyword such as $recent
    attribute :key, type: String
    attribute :title, type: String
    attribute :icon_url, type: String
    attribute :contents
    attribute :view_all_link, type: String
    attribute :column_number, type: Integer
  end
  
  # This dirty workaround is needed to avoid rails admin blowing up because the pluarize method
  # is redefined in TextHelper
  class TextHelperNamespace ; include ActionView::Helpers::TextHelper ; end
  def truncate(*args)
    TextHelperNamespace.new.truncate(*args)
  end
  
  def tag_to_category(tag, needs_related_tags = false, populate_desc = true)
    thumb_field = get_extra_fields!(tag)["thumbnail"]
    has_thumb = !thumb_field.blank? && upload_extra_field_present?(thumb_field)
    thumb_url = get_upload_extra_field_processor(thumb_field,"medium") if has_thumb
    if get_extra_fields!(tag).key? "description"
      description = truncate(get_extra_fields!(tag)["description"], :length => 150, :separator => ' ')
      long_description = get_extra_fields!(tag)["description"]
    else
      description = ""
      long_description = ""
    end
    header_field = get_extra_fields!(tag)["header_image"]
    has_header = !header_field.blank? && upload_extra_field_present?(header_field)
    header_image = get_upload_extra_field_processor(header_field,"original") if has_header
    
    icon_field = get_extra_fields!(tag)["icon"]
    has_icon = !icon_field.blank? && upload_extra_field_present?(icon_field)
    icon = get_upload_extra_field_processor(icon_field,"medium") if has_icon
    
    category_icon_field = get_extra_fields!(tag)["category_icon"]
    has_category_icon_field = !category_icon_field.blank? && upload_extra_field_present?(category_icon_field)
    category_icon = get_upload_extra_field_processor(category_icon_field,"medium") if has_category_icon_field
    
    BrowseCategory.new(
      type: "tag",
      id: tag.id,
      has_thumb: has_thumb, 
      thumb_url: thumb_url,
      title: tag.title,
      long_description: populate_desc ? long_description : nil,
      description: populate_desc ? description : nil,  
      detail_url: "/browse/category/#{tag.id}",
      created_at: tag.created_at.to_i,
      header_image_url: header_image,
      icon: icon,
      category_icon: category_icon,
      tags: needs_related_tags ? get_tag_ids_for_tag(tag) : []
    )
  end
  
  def tag_to_category_light(tag, needs_related_tags = false, populate_desc = true)
    thumb_field = get_extra_fields!(tag)["thumbnail"]
    has_thumb = thumb_field && upload_extra_field_present?(thumb_field)
    thumb_url = get_upload_extra_field_processor(thumb_field,"medium") if has_thumb
    if get_extra_fields!(tag).key? "description"
      description = truncate(get_extra_fields!(tag)["description"], :length => 150, :separator => ' ')
      long_description = get_extra_fields!(tag)["description"]
    else
      description = ""
      long_description = ""
    end
    header_field = get_extra_fields!(tag)["header_image"]
    has_header = !header_field.blank? && upload_extra_field_present?(header_field)
    header_image = get_upload_extra_field_processor(header_field,"original") if has_header
    
    icon_field = get_extra_fields!(tag)["icon"]
    has_icon = !icon_field.blank? && upload_extra_field_present?(icon_field)
    icon = get_upload_extra_field_processor(icon_field,"medium") if has_icon
    
    category_icon_field = get_extra_fields!(tag)["category_icon"]
    has_category_icon_field = !category_icon_field.blank? && upload_extra_field_present?(category_icon_field)
    category_icon = get_upload_extra_field_processor(category_icon_field,"medium") if has_category_icon_field
    
    BrowseCategory.new(
      type: "tag",
      id: tag.id,
      has_thumb: has_thumb, 
      thumb_url: thumb_url,
      title: tag.title,
      long_description: populate_desc ? long_description : nil,
      description: populate_desc ? description : nil,  
      detail_url: "/browse/category/#{tag.id}",
      created_at: tag.created_at.to_i,
      header_image_url: header_image,
      icon: icon,
      category_icon: category_icon,
      tags: needs_related_tags ? get_tag_ids_for_tag(tag) : []
    )
  end
  
  def cta_to_category(cta, populate_desc = true)
    BrowseCategory.new(
      type: "cta",
      id: cta.id, 
      has_thumb: cta.thumbnail.present?, 
      thumb_url: cta.thumbnail(:thumb), 
      title: cta.title, 
      description: populate_desc ? truncate(cta.description, :length => 150, :separator => ' ') : nil,
      long_description: populate_desc ? cta.description : nil,
      detail_url: "/call_to_action/#{cta.id}",
      created_at: cta.created_at.to_time.to_i,
      comments: get_number_of_comments_for_cta(cta),
      likes: get_number_of_likes_for_cta(cta),
      tags: get_tag_ids_for_cta(cta)
    )
  end
  
  def cta_to_category_light(cta, populate_desc = true)
    BrowseCategory.new(
      type: "cta",
      id: cta.id, 
      has_thumb: cta.thumbnail.present?, 
      thumb_url: cta.thumbnail(:thumb), 
      title: cta.title, 
      description: populate_desc ? truncate(cta.description, :length => 150, :separator => ' ') : nil,
      long_description: populate_desc ? cta.description : nil,
      detail_url: "/call_to_action/#{cta.id}",
      created_at: cta.created_at.to_time.to_i,
      comments: nil,
      likes: nil,
      status: nil,
      tags: nil
    )
  end
  
  def get_tag_ids_for_cta(cta)
    cache_short(get_tag_names_for_cta_key(cta.id)) do
      tags = {}
      cta.call_to_action_tags.each do |t|
        tags[t.tag.id] = t.tag.id
      end
      tags
    end
  end
  
  def get_tag_ids_for_tag(tag)
    cache_short(get_tag_names_for_tag_key(tag.id)) do
      tags = {}
      tag.tags_tags.each do |t| 
        tags[Tag.find(t.other_tag_id).id] = Tag.find(t.other_tag_id).id
      end
      tags  
    end
  end
  
  def user_for_registation_form()
    if current_user.aux
      aux = JSON.parse(current_user.aux)
      contest = aux[:contest]
      role = aux[:role]
    end

    {
      "day_of_birth" => current_user.day_of_birth,
      "month_of_birth" => current_user.month_of_birth,
      "year_of_birth" => current_user.year_of_birth,
      "gender" => current_user.gender,
      "location" => current_user.location, 
      "aux" => { 
        "contest" => contest,
        "terms" => role
      }
    }
  end

  def order_elements_by_ordering_meta(meta_ordering, elements)
    ordered_element_names = meta_ordering.split(",")
    if ordered_element_names.any?         
      ordered_elements = Array.new
      ordered_element_names.each do |element_name|
        elements.each do |element|
          if element.name == element_name
            ordered_elements << element
          end
        end
      end
      elements.each do |element|
        unless ordered_element_names.include?(element.name) 
          ordered_elements << element
        end
      end
      ordered_elements
    else
      elements
    end
  end

  def get_highlight_calltoactions()
    tag = Tag.find_by_name("highlight")
    if tag
      highlight_calltoactions = calltoaction_active_with_tag(tag.name, "DESC")
      order_elements(tag, highlight_calltoactions)
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
    if !anonymous_user?(user) || $site.anonymous_interaction
      user_interaction = user.user_interactions.find_by_interaction_id(interaction.id)
      expire_cache_key(get_share_interaction_daily_done_cache_key(user.id))
    end
    
    if user_interaction

      case interaction.resource_type.downcase
      when "share"
        aux = merge_aux(aux, user_interaction.aux)
      when "like"
        aux = { like: !(JSON.parse(user_interaction.aux)["like"]) }.to_json
      when "vote"
        aux_parse = JSON.parse(aux)
        aux_in_user_interaction = JSON.parse(user_interaction.aux)
        aux_in_user_interaction["vote"] = aux_parse["vote"]
        if aux_in_user_interaction["vote_info_list"].has_key?(aux_parse["vote"].to_s)
          aux_in_user_interaction["vote_info_list"][aux_parse["vote"]] = aux_in_user_interaction["vote_info_list"][aux_parse["vote"].to_s] + 1
        else
          aux_in_user_interaction["vote_info_list"][aux_parse["vote"]] = 1
        end
        aux = aux_in_user_interaction.to_json
      end

      unless interaction.resource.one_shot
        user_interaction.assign_attributes(counter: (user_interaction.counter + 1), answer_id: answer_id, like: like, aux: aux)
        UserCounter.update_counters(interaction, user_interaction, user, false) 
      end

    else

      if interaction.resource_type.downcase == "vote"
        aux_parse = JSON.parse(aux)
        aux_parse["vote_info_list"] = {
          aux_parse["vote"] => 1
        }
        aux = aux_parse.to_json
      end

      user_interaction = UserInteraction.new(user_id: user.id, interaction_id: interaction.id, answer_id: answer_id, aux: aux)
  
      if !(anonymous_user?(user) || $site.anonymous_interaction)
        UserCounter.update_counters(interaction, user_interaction, user, true)
      end
    end

    unless anonymous_user?(user)
      expire_cache_key(get_cta_completed_or_reward_status_cache_key(get_main_reward_name, interaction.call_to_action_id, user.id))
    end

    if anonymous_user?(user) # TODO: this branch is not tested!
      outcome = compute_outcome(user_interaction)
    else
      outcome = compute_save_and_notify_outcome(user_interaction)
    end
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

    if !anonymous_user?(user) || $site.anonymous_interaction
      user_interaction.save
    end
  
    [user_interaction, outcome]
  
  end
  
  def get_max(collection, &comparison)
    result = nil
    if collection
      collection.each do |element|
        if result.nil?
          result = element
        else
          cmp_result = yield(result, element)
          if cmp_result > 0
            result = element
          end
        end
      end
    end
    result
  end
  
  def interaction_done?(interaction)
    return current_user && UserInteraction.find_by_user_id_and_interaction_id(current_user.id, interaction.id)
  end

  def get_tag_to_rewards()
    cache_short("tag_to_rewards") do
      rewards = Reward.all
      id_to_reward = {}
      rewards.each do |r|
        id_to_reward[r.id] = r
      end

      tag_to_rewards = {}
      RewardTag.joins(:tag).select('tags.name, reward_id').each do |reward_tag|
        (tag_to_rewards[reward_tag.name] ||= Set.new) << id_to_reward[reward_tag.reward_id]
      end

      tag_to_rewards
    end
  end
  
  def get_tag_to_my_rewards(user)
    get_user_rewards_from_cache(user)[0]
  end
  
  def get_user_rewards_from_cache(user)
    cache_short(get_user_rewards_cache_key(user.id)) do
      rewards = Reward.joins(:user_rewards).select("rewards.*").where("user_rewards.user_id = ?", user.id)
      id_to_reward = {}
      rewards.each do |r|
        id_to_reward[r.id] = r
      end
      
      name_to_reward = {}
      rewards.each do |r|
        name_to_reward[r.name] = r
      end
      
      tag_to_rewards = {}
      RewardTag.joins(:tag).select('tags.name, reward_id').each do |reward_tag|
        if id_to_reward[reward_tag.reward_id]
          (tag_to_rewards[reward_tag.name] ||= Set.new) << id_to_reward[reward_tag.reward_id]
        end
      end
      [tag_to_rewards, name_to_reward] 
    end
  end

  def get_tag_with_tag_about_call_to_action(calltoaction, tag_name)
    cache_short get_tag_with_tag_about_call_to_action_cache_key(calltoaction.id, tag_name) do
      Tag.includes(tags_tags: :other_tag).includes(:call_to_action_tags).where("other_tags_tags_tags.name = ? AND call_to_action_tags.call_to_action_id = ?", tag_name, calltoaction.id).order("call_to_action_tags.updated_at DESC").to_a
    end
  end
  
  def get_tag_with_tag_about_reward(reward, tag_name)
    cache_short get_tag_with_tag_about_reward_cache_key(reward.id, tag_name) do
      Tag.includes(tags_tags: :other_tag).includes(:reward_tags).where("other_tags_tags_tags.name = ? AND reward_tags.reward_id = ?", tag_name, reward.id).to_a
    end
  end
  
  def construct_conditions_from_query(query, field)
    query.gsub!(/\W+/, ' ')
    conditions = ""
    query.split(" ").each do |term|
      unless conditions.blank?
        conditions += " OR #{field} ILIKE #{ActiveRecord::Base.connection.quote("%#{term}%")}"
      else
        conditions += "#{field} ILIKE #{ActiveRecord::Base.connection.quote("%#{term}%")}"
      end
    end
    conditions
  end

  def get_tags_with_tag(tag_name)
    cache_short get_tags_with_tag_cache_key(tag_name) do
      hidden_tags_ids = get_hidden_tag_ids
      if hidden_tags_ids.any?
        Tag.joins(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ? AND tags.id not in (?)", tag_name, hidden_tags_ids).to_a
      else
        Tag.joins(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ?", tag_name).to_a
      end
    end
  end
  
  def get_tags_with_tag_with_match(tag_name, query = "")
    conditions = construct_conditions_from_query(query, "tags.title")
    category_tag_ids = get_category_tag_ids()
    if conditions.empty?
      tags = Tag.includes(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ? AND (#{conditions})", tag_name).order("tags.created_at DESC").to_a
    else
      tags = Tag.includes(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ? AND (#{conditions}) AND tags.id in (?)", tag_name, category_tag_ids).order("tags.created_at DESC").to_a
    end
    filter_results(tags, query)
  end
  
  def get_tags_with_match(query = "")
    conditions = construct_conditions_from_query(query, "tags.title")
    category_tag_ids = get_category_tag_ids()
    if conditions.empty?
      tags = Tag.includes(:tags_tags).where("id in (?)", category_tag_ids).order("tags.created_at DESC").to_a
    else
      tags = Tag.includes(:tags_tags).where("#{conditions} AND id in (?)", category_tag_ids).order("tags.created_at DESC").to_a
    end
    filter_results(tags, query)
  end
  
  def get_ctas_with_tag(tag_name)
    cache_short get_ctas_with_tag_cache_key(tag_name) do
      CallToAction.active.joins(:call_to_action_tags => :tag).where("tags.name = ? AND call_to_actions.user_id IS NULL", tag_name).to_a
    end
  end
  
  def get_user_ctas_with_tag(tag_name, offset = 0, limit = 6)
    cache_short get_user_ctas_with_tag_cache_key(tag_name) do
        CallToAction.active_with_media.joins(:call_to_action_tags => :tag).where("tags.name = ? AND call_to_actions.user_id IS NOT NULL", tag_name).offset(offset).limit(limit).to_a
    end
  end
  
  def get_ctas_with_tag_with_match(tag_name, query = "")
    conditions = construct_conditions_from_query(query, "call_to_actions.title")
    ctas = CallToAction.active.includes(call_to_action_tags: :tag).includes(:interactions).where("tags.name = ? AND (#{conditions})", tag_name).order("call_to_actions.created_at DESC").to_a
    filter_results(ctas, query)
  end
  
  def get_ctas_with_match(query = "")
    conditions = construct_conditions_from_query(query, "call_to_actions.title")
    if conditions.empty?
      ctas = CallToAction.active.includes(:interactions).where("user_id IS NULL").order("call_to_actions.created_at DESC").to_a
    else
      ctas = CallToAction.active.includes(:interactions).where("#{conditions} AND user_id IS NULL").order("call_to_actions.created_at DESC").to_a
    end
    filter_results(ctas, query)
  end
  
  def filter_results(results, query)
    regexp = Regexp.new(query.split(/\W+/).map { |term| "(\\W+#{term}\\W+)" }.join("|"), Regexp::IGNORECASE)
    filtered_results = []
    results.each do |result|
      title = " #{result.title} "
      unless regexp.match(title).nil?
        filtered_results << result
      end
    end
    filtered_results
  end
  
  def get_ctas_with_tags(tags_name, with_user_cta = false)
    cache_short get_ctas_with_tags_cache_key(tags_name, with_user_cta) do
      tag_ids = Tag.where("name in (?)", tags_name).pluck(:id)
      if with_user_cta
        CallToAction.active.includes(call_to_action_tags: :tag).where("tags.id in (?) AND call_to_actions.user_id IS NULL", tag_ids).to_a
      else
        CallToAction.active.includes(call_to_action_tags: :tag).where("tags.id in (?)", tag_ids).to_a
      end
    end
  end
  
  def get_all_ctas_with_tag(tag_name)
    cache_short get_ctas_with_tag_cache_key(tag_name) do
      CallToAction.includes(call_to_action_tags: :tag).where("tags.name = ?", tag_name).to_a
    end
  end

  def get_all_active_ctas()
    cache_short get_all_active_ctas_cache_key() do
      CallToAction.active.to_a
    end
  end
  
  def get_rewards_with_tag(tag_name)
    cache_short get_rewards_with_tag_cache_key(tag_name) do
      Reward.includes(reward_tags: :tag).where("tags.name = ?", tag_name).to_a
    end
  end
  
  def get_last_rewards_for_tag(tag_name)
    cache_short get_last_rewards_for_tag(tag_name, current_user.id) do
      
      
      last_reward = current_or_anonymous_user.user_rewards.includes(:reward).where("rewards.name = '#{reward_name}'").order("rewards.updated_at DESC").first
      if last_reward
        last_reward
      else
        CACHED_NIL
      end
    end
  end
  
  def get_max_reard(rewards)
    rewards.order("updated_at DESC").first
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

  def cta_to_reward_statuses_by_user(user, ctas, reward_name) 
    cta_to_reward_statuses = cache_long(get_cta_to_reward_statuses_by_user_cache_key(user.id)) do
      result = {}
      ctas.each do |cta|
        result[cta.id] = cta_reward_statuses(user, cta, reward_name)
      end
      result
    end
    updated = false
    ctas.each do |cta|
      unless cta_to_reward_statuses.key? cta.id
        updated = true
        cta_to_reward_statuses[cta.id] = cta_reward_statuses(user, cta, reward_name)
      end
    end
    if updated
      cache_write_long(get_cta_to_reward_statuses_by_user_cache_key(user.id), cta_to_reward_statuses)
    end
    cta_to_reward_statuses
  end

  def cta_reward_statuses(user, cta, reward_name)
    if call_to_action_completed?(cta)
      nil
    else
      winnable_outcome, interaction_outcomes, sorted_interactions = predict_max_cta_outcome(cta, user)
      winnable_outcome["reward_name_to_counter"][reward_name]
    end
  end


  def call_to_action_completed?(cta)
    if current_user
      require_to_complete_interactions = interactions_required_to_complete(cta)

      if require_to_complete_interactions.count == 0
        return false
      end

      require_to_complete_interactions_ids = require_to_complete_interactions.map { |i| i.id }
      interactions_done = UserInteraction.where("user_interactions.user_id = ? and interaction_id IN (?)", current_user.id, require_to_complete_interactions_ids)
      require_to_complete_interactions.count == interactions_done.count

    else
      false
    end
  end

  def compute_call_to_action_completed_or_reward_status(reward_name, calltoaction)
    call_to_action_completed_or_reward_status = cache_short(get_cta_completed_or_reward_status_cache_key(reward_name, calltoaction.id, current_or_anonymous_user.id)) do
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
      win_reward_count = (JSON.parse(user_interaction.outcome)["win"]["attributes"]["reward_name_to_counter"].fetch(reward_name, 0) rescue 0)
      correct_answer_outcome = (JSON.parse(user_interaction.outcome)["correct_answer"] rescue nil)
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
  
  def get_current_property_point
    get_counter_about_user_reward(get_current_property_point_reward_name)
  end  

  def get_current_property_point_reward_name
    $context_root.nil? ? "point" : "#{$context_root}-point"
  end

  def get_counter_about_user_reward(reward_name, all_periods = false)
    if current_user
      reward_points = cache_short(get_reward_points_for_user_key(reward_name, current_user.id)) do
        
        reward_points = { general: 0 }
        $site.periodicity_kinds.each do |periodicity_kind|
          reward_points[:periodicity_kind] = 0
        end

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
    user_reward = get_user_rewards_from_cache(current_user)[1]
    !user_reward[reward_name].nil?
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
        (100 / interaction.resource.answers.count.to_f).round
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

  def anonymous_user?(user)
    anonymous_user.id == user.id
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

  def small_mobile_device?()
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
      return anon_avatar()
    end
  end

  def user_avatar user, size = "normal"
    begin
      user.avatar_selected_url.present? ? user.avatar_selected_url : anon_avatar()
    rescue
      anon_avatar()
    end
  end

  def anon_avatar
    ActionController::Base.helpers.asset_path("#{$site.assets["anon_avatar"]}")
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
    notify_outcome(user_interaction.user_id, outcome)
    outcome
  end

  def notify_outcome(user_id, outcome)
    to_be_notified_reward_names = get_to_be_notified_reward_names
    outcome.reward_name_to_counter.each do |r|
      reward_name = r.first
      if to_be_notified_reward_names.include?(reward_name)
        reward = get_reward_by_name(reward_name)
        html_notice = render_to_string "/easyadmin/easyadmin_notice/_notice_template", locals: { reward: reward }, layout: false, formats: :html
        notice = create_notice(:user_id => user_id, :html_notice => html_notice, :viewed => false, :read => false)
        # notice.send_to_user(request)
        expire_cache_key(notification_cache_key(user_id))
      end
    end
  end

  # Assigns (or unlocks) rewards to an user based just on his/her other rewards, not on an interaction done
  # This methods should be called when rules have been updated with new "context" rules (i.e. those assigning rewards
  # based on other rewards or counters) 
  def compute_save_and_notify_context_rewards(user)
    user_interaction = MockedUserInteraction.new(MockedInteraction.new, user, 1, false)
    compute_save_and_notify_outcome(user_interaction)    
  end

  def compute_and_save_context_rewards(user)
    user_interaction = MockedUserInteraction.new(MockedInteraction.new, user, 1, false)
    compute_and_save_outcome(user_interaction)    
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
    cache_short(get_main_reward_image_cache_key) do
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
  
  def get_cta_date(cta_date)
    "#{cta_date.day} #{from_month_to_name(cta_date.month)}"
  end
  
  def from_month_to_name(month)
    MONTH_NAMES[month]
  end
  
  def get_twitter_title_for_share(cta)
    share_interaction = cta.interactions.find_by_resource_type("Share")
    if share_interaction
      share_resource = share_interaction.resource
      share_info = JSON.parse(share_resource.providers)
      if share_info['twitter']['message'].present?
        share_info['twitter']['message']
      else
        cta.title
      end
    else
      cta.title
    end
  end
  
  def extra_field_to_html(field)
    ac = ActionController::Base.new()
    ac.render_to_string "/extra_fields/_extra_field_#{field['type']}", locals: { label: field['label'], name: field['name']  }, layout: false, formats: :html
  end

  def not_logged_from_omniauth(auth, provider)  
    user_auth =  Authentication.find_by_provider_and_uid(provider, auth.uid);
    if user_auth
      # Ho gia' agganciato questo PROVIDER, mi basta recuperare l'utente per poi aggiornarlo.
      # Da tenere conto che vengono salvate informazioni differenti a seconda del PROVIDER di provenienza.
      user = user_auth.user
      user_auth.update_attributes(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          avatar: auth.info.image,
      )

      from_registration = false

    else
      # Verifico se esiste l'utente con l'email del provider selezionato.
      unless auth.info.email && (user = User.find_by_email(auth.info.email))
        password = Devise.friendly_token.first(8)
        user = User.new(
          password: password,
          password_confirmation: password,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          email: auth.info.email,
          avatar_selected: provider,
          privacy: nil # TODO: TENANT
          )
        from_registration = true
      else
        from_registration = false
      end 

      # Recupero l'autenticazione associata al provider selezionato.
      # Da tenere conto che vengono salvate informazioni differenti a seconda del provider di provenienza.
      user.authentications.build(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          provider: provider,
          avatar: auth.info.image,
          aux: auth.to_json
      )

      user.required_attrs = get_site_from_request(request)["required_attrs"]
      user.aux = JSON.parse(user.aux) if user.aux.present?
      user.save
    end 
    
    return user, from_registration
  end
  
  # Get max reward
  #   rward_name      - name of the reward type (eg: level, badge)
  #   extra_cache_key - further param to handle name clashing clash in case of multi property
  def get_max_reward(reward_name, extra_cache_key = "")
    cache_short(get_max_reward_key(reward_name, current_user.id, extra_cache_key)) do
      rewards, use_property = rewards_by_tag(reward_name, current_user)
      reward = nil
      if use_property
        if !rewards.empty?
          reward = get_max(rewards[$context_root]) do |x,y| if x.updated_at > y.updated_at then -1 elsif x.updated_at < y.updated_at then 1 else 0 end end
        end 
      elsif !rewards.nil?
        rweard = get_max(rewards) do |x,y| if x.updated_at > y.updated_at then -1 elsif x.updated_at < y.updated_at then 1 else 0 end end
      end
      
      if reward.nil?
        CACHED_NIL
      else
        reward
      end
    end
  end
  
  def rewards_by_tag(tag_name, user = nil)
    if user.nil?
      tag_to_rewards = get_tag_to_rewards()
    else
      tag_to_rewards = get_tag_to_my_rewards(user)
    end
    # rewards_from_param can include badges or levels 
    rewards_from_param = tag_to_rewards[tag_name]

    property_tags = get_tags_with_tag("property")

    if property_tags.present?

      rewards_to_show = Hash.new

      property_tag_names = property_tags.map{ |tag| tag.name }
      
      tag_to_rewards.each do |tag_name, rewards|
        if property_tag_names.include?(tag_name) && rewards_from_param
          rewards_to_show[tag_name] = rewards & rewards_from_param
        end
      end

      are_properties_used = are_properties_used?(rewards_to_show)
     
      unless are_properties_used
        rewards_to_show = rewards_from_param
      end

    else
      are_properties_used = false
      rewards_to_show = rewards_from_param
    end

    [rewards_to_show, are_properties_used]
  end

  def are_properties_used?(rewards_to_show)
    not_empty_properties_counter = 0
    rewards_to_show.each do |tag_name, rewards|
      not_empty_properties_counter += 1 if rewards.any?  
    end

    not_empty_properties_counter > 0
  end
  
  def get_avatar_list
    folder = Setting.find_by_key("avatar.folder").value
    avatars = []
    Setting.find_by_key("avatar.file_names").value.split(",").each do |avatar|
      avatars << { id: avatar.split(".")[0], url: "#{folder}#{avatar}" }
    end
    avatars
  end

  def get_tag_from_params(name)
    tag = cache_short(get_tag_cache_key(name)) do
      tag = Tag.find_by_name(name)
      tag ? tag : CACHED_NIL
    end
    cached_nil?(tag) ? nil : tag
  end

  def get_main_reward_name() 
    $context_root ? "#{$context_root}-#{MAIN_REWARD_NAME}" : MAIN_REWARD_NAME
  end
  
  def get_property_from_cta(cta)
    properties_tag = get_tag_with_tag_about_call_to_action(cta, "property")
    if properties_tag.empty?
      ""
    else
      "#{properties_tag.first.name}"
    end
  end
  
  def get_hidden_tag_ids
    cache_short(get_hidden_tags_cache_key) do
      Tag.includes(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ? ", "hide-tag").map{|t| t.id}
    end
  end
  
  def get_number_of_page(elements, per_page)
    if elements == 0
      0
    elsif elements < per_page
      1
    elsif elements % per_page == 0
      elemetns / per_page
    else
      (elements / per_page) + 1
    end
  end

  def default_aux(other)

    if other && other.has_key?(:calltoaction)
      related_calltoaction_info = "TODO" # get_disney_related_calltoaction_info(calltoaction, current_property, related_tag_name, in_gallery)
    end

    if other && other.has_key?(:calltoaction_evidence_info)
      calltoaction_evidence_info = cache_short(get_evidence_calltoactions_in_property_for_user_cache_key(current_or_anonymous_user.id, current_property.id)) do  
        highlight_calltoactions = get_disney_highlight_calltoactions(current_property)
        calltoactions_in_property = get_disney_ctas(current_property)
        if highlight_calltoactions.any?
          calltoactions_in_property = calltoactions_in_property.where("call_to_actions.id NOT IN (?)", highlight_calltoactions.map { |calltoaction| calltoaction.id })
        end

        calltoactions = highlight_calltoactions + calltoactions_in_property.limit(3).to_a
        calltoaction_evidence_info = []
        calltoactions.each do |calltoaction|
          calltoaction_evidence_info << build_thumb_calltoaction(calltoaction)
        end

        calltoaction_evidence_info
      end
    end

    aux = {
      "tenant" => $site.id,
      "anonymous_interaction" => $site.anonymous_interaction,
      "main_reward_name" => MAIN_REWARD_NAME,
      "calltoaction_evidence_info" => calltoaction_evidence_info,
      "related_calltoaction_info" => related_calltoaction_info,
      "mobile" => small_mobile_device?(),
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice]
    }

    if other
      other.each do |key, value|
        aux[key] = value unless aux.has_key?(key.to_s)
      end
    end

    aux

  end

  def get_calltoactions_count(calltoactions_in_page, aux)
    if calltoactions_in_page < $site.init_ctas
      calltoactions_in_page
    else
      cache_short(get_calltoactions_count_in_property_cache_key(property.id)) do
        CallToAction.active.count
      end
    end
  end
  
  def order_elements(tag, elements)
    meta_ordering = get_extra_fields!(tag)["ordering"]
    if meta_ordering
      elements = order_elements_by_ordering_meta(meta_ordering, elements)
    end
    elements
  end
  
  def get_cta_vote_info(cta_id)
    result = CacheVote.where("call_to_action_id = ?", cta_id).order("version DESC").first
    vote_info = {"total" => 0}
    unless result.nil?
      vote_info['total'] = result.vote_sum
    end
    vote_info
  end
  
end
