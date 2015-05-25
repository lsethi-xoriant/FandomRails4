#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

module ApplicationHelper

  include CacheHelper
  include RewardingSystemHelper
  include RewardHelper
  include NoticeHelper
  include BrowseHelper
  include GrafitagHelper
  include LogHelper
  include SeoHelper
  include EventHandlerHelper
  include CacheKeysHelper
  include CommentHelper
  include CallToActionHelper
  include CaptchaHelper
  include CalendarHelper
  include ViewHelper
  include LinkedCallToActionHelper
  include CacheExpireHelper
  include PeriodicityHelper
  include ModelHelper
  include RewardingRuleCheckerHelper
  include RewardingRulesCollectorHelper
  include FandomUtils
  include FilterHelper
  include ContentHelper
  include UserInteractionHelper
  include TagHelper
  include ActionView::Helpers::SanitizeHelper
  
  # This dirty workaround is needed to avoid rails admin blowing up because the pluarize method
  # is redefined in TextHelper
  class TextHelperNamespace ; include ActionView::Helpers::TextHelper ; end
  def truncate(*args)
    TextHelperNamespace.new.truncate(*args)
  end

  def get_property()
    property_name = $context_root || $site.default_property
    if(property_name)
      get_tag_from_params(property_name)
    else
      nil
    end
  end


  def get_menu_items(property = nil)
    result = []

    menu_item_tag = get_tag_from_params("menu-item")
    
    menu_item_tag_ids = [menu_item_tag.id]
    if property
      menu_item_tag_ids << property.id
    end

    menu_items = get_tags_with_tags_in_and(menu_item_tag_ids)

    if menu_items.any?    
      menu_items = order_elements(menu_item_tag, menu_items)
      
      menu_items.each do |item|
        extra_fields = get_extra_fields!(item)
        result << {
          "id" => item.id,
          "name" => item.name,
          "slug" => item.slug,
          "title" => item.title,
          "extra_fields" => extra_fields
        }
      end
    end

    result
  end

  def build_current_user() 
    if current_user
      profile_completed = disney_profile_completed?()
      current_user_for_view = {
        "facebook" => current_user.facebook($site.id),
        "twitter" => current_user.twitter($site.id),
        "main_reward_counter" => get_point,
        "username" => current_user.username,
        "level" => nil, # (get_current_level["level"]["name"] rescue "nessun livello"),
        "notifications" => get_unread_notifications_count(),
        "avatar" => current_avatar
      }
    else
      current_user_for_view = nil
    end
    current_user_for_view.to_json
  end
  
  def get_cta_event_start_end(cta_interactions)
    event_range_info = {
      start_date: nil,
      end_date: nil,
      ical_id: nil
    }
    if cta_interactions
      cta_interactions.each do |interaction|
        if interaction[:interaction_info][:resource_type].downcase == 'download' && interaction[:interaction_resource][:ical_fields]
          ical_fields = JSON.parse(interaction[:interaction_resource][:ical_fields])
          event_range_info[:ical_id] = interaction[:interaction_info].id
          if ical_fields['start_datetime']
            event_range_info[:start_date] = ical_fields['start_datetime']['value']
          end
          if ical_fields['end_datetime']
            event_range_info[:end_date] = ical_fields['end_datetime']['value'] 
          end
        end
      end
    end
    event_range_info
  end

  def order_elements_by_ordering_meta(meta_ordering, elements)
    name_to_element = {}
    elements.each do |e| 
      name_to_element[e.name] = e
    end
    result = []
    meta_ordering.split(",").each do |name|
      name = name.strip
      if name_to_element.key? name
        result << name_to_element.delete(name)
      end
    end
    result + name_to_element.values
  end

  def get_highlight_ctas(property = nil)
    highlight_tag = get_tag_from_params("highlight")

    if property.present?
      highlight_tag = get_tags_with_tags_in_and([highlight_tag.id, property.id]).first
    end

    if highlight_tag
      highlight_ctas = get_ctas(highlight_tag)
      if highlight_ctas
        order_elements(highlight_tag, highlight_ctas)
      else
        []
      end
    else
      []
    end

  end

  def get_highlight_calltoactions(property = nil)
    get_highlight_ctas(property)
  end

  def get_intesa_expo_highlight_calltoactions()
    tag_highlight = 
    if tag_highlight
      ctas = get_intesa_expo_ctas(tag_highlight)
      order_elements(tag_highlight, ctas)
    else
      []
    end
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
  
  def get_extra_key_from_params(params)
    extra_key = []
    if params[:conditions]
      params[:conditions].map do |k,v|
        if k != "exclude_cta_ids" && k != "exclude_tag_ids"
          if v.kind_of?(Array)
            extra_key << "#{k}_#{v.join("_")}"
          else
            extra_key << "#{k}_#{v}"
          end
        end
      end
    end
    if params.include?(:ical_start_datetime) || params.include?(:ical_end_datetime)
      if params[:ical_start_datetime]
        extra_key << Time.parse(params[:ical_start_datetime]).strftime("%Y-%m-%d_%H-%M-%S")
      end
      if params[:ical_end_datetime]
        extra_key << Time.parse(params[:ical_end_datetime]).strftime("%Y-%m-%d_%H-%M-%S")
      end
    end
    if params[:limit]
      extra_key << "limit_#{params[:limit][:offset]}_#{params[:limit][:perpage]}"
    end
    extra_key.join("_")
  end
  
  # Adds to a query some conditions on ical fields.
  #   query  - the active record query where the conditions should be added
  #   params - an hash containing start/end datetimes
  #   allow_null - when true the filter is only applied to download interactions so that other interactions are included in the result
  def add_ical_fields_to_where_condition(query, params, allow_null = false)
    if allow_null
      allow_null_condition = "ical_fields is null OR"
    else
      allow_null_condition = ""
    end
    if params[:ical_start_datetime]
      query = query.where("#{allow_null_condition} cast(\"ical_fields\"->'start_datetime'->>'value' AS timestamp) >= ?", params[:ical_start_datetime])
    end
    if params[:ical_end_datetime]
      query = query.where("#{allow_null_condition} cast(\"ical_fields\"->'end_datetime'->>'value' AS timestamp) <= ?", params[:ical_end_datetime])
    end
    query
  end
  
  # Public: Construct an sql condition string from hash of params. 
  #
  # params  - The Hash with params
  #           params hash is so formed: { conditions: { condition_name: condition_value, ... }, 
  #                                       limit: { offset: offset_value, perpage: perpage_elements } }
  #           conditions_name accepted:
  #             without_user_cta: exclude cta user generated
  #             exclude_cta_ids: exclude from results cta with listed ids
  #
  # Returns the where conditions string
  def get_cta_where_clause_from_params(params)
    where_clause = []
    if params[:conditions]
      if params[:conditions].fetch(:without_user_cta, false) 
        where_clause << "call_to_actions.user_id IS NULL"
      end
      if params[:conditions][:exclude_cta_ids] && params[:conditions][:exclude_cta_ids].any?
        where_clause << "call_to_actions.id NOT IN (#{params[:conditions][:exclude_cta_ids].join(',')})"
      end
    end
    where_clause = where_clause.join(" AND ")
    where_clause
  end
  
  # Public: Construct an sql condition string from hash of params
  #
  # params  - The Hash with params
  #           params hash is so formed: { conditions: { condition_name: condition_value, ... }, limit: { offset: offset_value, perpage: perpage_elements } }
  #           conditions_name accepted:
  #             exclude_tag_ids: exclude from results tag with listed ids
  #
  # Returns the where conditions string
  def get_tag_where_clause_from_params(params)
    where_clause = []
    if params[:conditions]
      
    end
    where_clause = where_clause.join(" AND ")
    where_clause
  end

  def get_all_active_ctas()
    cache_short get_all_active_ctas_cache_key() do
      CallToAction.active.to_a
    end
  end
  
  def get_rewards_with_tag(tag_name)
    cache_short get_rewards_with_tag_cache_key(tag_name) do
      Reward.includes(reward_tags: :tag).where(tags: { name: tag_name }).to_a
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

  def calltoaction_active_with_tag(tag, order)
    CallToAction.joins(:call_to_action_tags => [:tag]).where("activated_at <= ? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NOT NULL AND tags.name = ?)", Time.now, tag).order("activated_at #{order}")
  end

  def calltoaction_coming_soon_with_tag(tag, order)
    CallToAction.joins(:call_to_action_tags => [:tag]).where("activated_at>? AND activated_at IS NOT NULL AND media_type<>'VOID' AND (call_to_action_tags.id IS NOT NULL AND tags.name=?)", Time.now, tag).order("activated_at #{order}")
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
                  "button:  \"//placehold.it/50x50\"," +
                  "icon:     \"//placehold.it/50x50\"," +
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
    ac.render_to_string "/extra_fields/_extra_field_#{field['type']}", locals: { label: field['label'], name: field['name'], is_required: field['required']  }, layout: false, formats: :html
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
  
  def get_hidden_tag_ids
    cache_short(get_hidden_tags_cache_key) do
      Tag.includes(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ? ", "hide-tag").references(:other_tags_tags_tags).map{|t| t.id}
    end
  end

  def is_ugc?(cta)
    return cta.user_id.present?
  end

  def init_related_ctas(cta, property = nil)
    other_tags = []
    if is_ugc?(cta)        
      related_tag = get_cta_tag_tagged_with(cta, "gallery")
    else
      related_tag = get_cta_tag_tagged_with(cta, "miniformat")
      if related_tag.nil? && property.present?
        related_tag = property
      end
      if property.present?
        other_tags = [property]
      end
    end

    # TODO: remove 8 hardcoded
    [get_content_previews_excluding_ctas(related_tag.name, other_tags, [cta.id], 8), related_tag]
  end

  def init_property_info(property)
    if property.present?
      property_image = get_extra_fields!(property)["image"]
      if property_image.present?
        property_image_thumb = get_upload_extra_field_processor(property_image, :thumb)
      end
      {
        "id" => property.id,
        "title" => property.title,
        "name" => property.name,
        "extra_fields" => get_extra_fields!(property),
        "image" => property_image_thumb
      }
    else
      nil
    end
  end

  def init_property_info_list()
    property_tag = get_tag_from_params("property")
    if property_tag
      properties = order_elements(property_tag, get_tags_with_tag("property"))
      if properties.any?
        property_info_list = []
        properties.each do |property|
          property_extra_fields = get_extra_fields!(property)
          if property_extra_fields["image"].present?
            property_image_thumb = get_upload_extra_field_processor(property_extra_fields["image"], :thumb)
          end
           if property_extra_fields["image_hover"].present?
            property_image_hover_thumb = get_upload_extra_field_processor(property_extra_fields["image_hover"], :thumb)
          end
          property_info_list << {
            "id" => property.id,
            "name" => property.name,
            "extra_fields" => get_extra_fields!(property),
            "title" => property.title,
            "image" => property_image_thumb,
            "image_hover" => property_image_hover_thumb
          }
        end
        property_info_list
      else
        nil
      end
    else
      nil
    end
  end

  def get_ugc_cta(gallery_tag)
    # gallery cta does not have the user id set
    params = { 
      conditions: { 
        without_user_cta: true 
      }
    }
    get_ctas_with_tags_in_or([gallery_tag.id], params).first
  end

  def build_thumb_cta(cta)

    if cta.interactions
      interaction_ids = cta.interactions.map { |interaction| interaction.id }
    end

    {
      "id" => cta.id,
      "slug" => cta.slug,
      "status" => compute_call_to_action_completed_or_reward_status(get_main_reward_name(), cta, anonymous_user),
      "thumbnail_carousel_url" => cta.thumbnail(:carousel),
      "thumbnail_medium_url" => cta.thumbnail(:medium),
      "title" => cta.title,
      "description" => cta.description,
      "flag" => build_grafitag_for_calltoaction(cta, "flag"),
      "interaction_ids" => interaction_ids
    }

  end

  def adjust_thumb_ctas(cta_info_list)
    interaction_ids = []
    cta_info_list.each do |cta|
      interaction_ids = interaction_ids + cta["interaction_ids"]
    end
    if interaction_ids.any?
      interactions = Interaction.where(id: interaction_ids)
      counters = ViewCounter.where(ref_type: 'interaction', ref_id: interaction_ids)
      cta_info_list.each do |cta_info|
        cta_info["interaction_ids"].each do |interaction_id|
          interaction = find_content_in_array_by_id(interactions, interaction_id)
          counter = find_interaction_in_counters(counters, interaction_id)
          cta_info[interaction.resource_type.downcase] = counter ? counter.counter : 0
        end
      end
    end
  end

  def adjust_thumb_cta_for_current_user(cta_info_list)
    cta_ids = cta_info_list.map { |cta| cta["id"] }
    ctas = CallToAction.where(id: cta_ids)

    cta_info_list.each do |cta_info|
      cta = find_in_calltoactions(ctas, cta_info["id"])
      main_reward_name = get_main_reward_name()
      cta_info["status"] = compute_call_to_action_completed_or_reward_status(main_reward_name, cta)
    end
    cta_info_list
  end

  def default_aux(other, calltoaction_info_list = nil)
    property = get_property()

    property_info = init_property_info(property)
    property_info_list = init_property_info_list()

    if other && (other.has_key?(:calltoaction) || other.has_key?("calltoaction"))
      cta = other[:calltoaction] || other["calltoaction"]
      related_ctas, related_tag = init_related_ctas(cta, property)

      if is_ugc?(cta)        
        ugc_cta = get_ugc_cta(related_tag)
      else
        ugc_cta = nil
      end

    else
      related_ctas = nil
    end

    if other && other.has_key?(:calltoaction_evidence_info)
      cache_key = property.present? ? "in_#{property.name}" : "without_property"
      cache_timestamp = get_cta_max_updated_at()
      
      evidence_ctas_info_list = cache_forever(get_evidence_ctas_cache_key(cache_key, cache_timestamp)) do
        highlight_ctas = get_highlight_ctas(property)
        ctas = get_ctas(property)

        # TODO: remove 3 hardcoded
        if highlight_ctas.any?
          highlight_cta_ids = highlight_ctas.map { |cta| cta.id }
          evidence_ctas = ctas.where("call_to_actions.id NOT IN (?)", highlight_cta_ids).limit(3).to_a
          evidence_ctas = evidence_ctas + highlight_ctas
        else
          evidence_ctas = ctas.limit(3).to_a
        end

        evidence_ctas_info_list = []
        evidence_ctas.each do |cta|
          evidence_ctas_info_list << build_thumb_cta(cta)
        end

        evidence_ctas_info_list
      end

      max_user_interaction_updated_at = from_updated_at_to_timestamp(current_or_anonymous_user.user_interactions.maximum(:updated_at))
      max_user_reward_updated_at = from_updated_at_to_timestamp(current_or_anonymous_user.user_rewards.where("period_id IS NULL").maximum(:updated_at))
      user_cache_key = get_user_interactions_in_evidence_cta_info_list_cache_key(current_or_anonymous_user.id, cache_key, "#{max_user_interaction_updated_at}_#{max_user_reward_updated_at}")

      if current_user
        evidence_ctas_info_list = cache_forever(user_cache_key) do
          adjust_thumb_cta_for_current_user(evidence_ctas_info_list)
        end
      end

      adjust_thumb_ctas(evidence_ctas_info_list)

    else
      evidence_ctas_info_list = nil
    end

    @aux = {
      "tenant" => $site.id,
      "free_provider_share" => $site.free_provider_share,
      "anonymous_interaction" => $site.anonymous_interaction,
      "property_info" => property_info,
      "property_info_list" => property_info_list,
      "calltoaction_evidence_info" => evidence_ctas_info_list,
      "related_calltoaction_info" => related_ctas,
      "mobile" => small_mobile_device?(),
      "enable_comment_polling" => get_deploy_setting('comment_polling', true),
      "flash_notice" => flash[:notice],
      "ugc_cta" => ugc_cta,
      "menu_items" => get_menu_items(property)
    }

    if other
      other.each do |key, value|
        @aux[key] = value unless @aux.has_key?(key.to_s)
      end
    end

    @aux

  end
  
  def order_elements(tag, elements)
    meta_ordering = get_extra_fields!(tag)["ordering"]
    if meta_ordering
      elements = order_elements_by_ordering_meta(meta_ordering, elements)
    end
    elements
  end
  
  def get_cta_vote_info(interaction_id)
    cache_short(get_cache_votes_for_interaction(interaction_id)) do
      result = UserInteraction.where("interaction_id = ? ", interaction_id).sum("CAST(aux->>'vote' as integer)")
      vote_info = { "total" => 0 }
      vote_info['total'] = result
      vote_info
    end
  end
  
  # This methods is used to obtain an Hash that will be used to attach interactions to call to actions that have been transformed into content previews.
  #   cta_ids - the list of cta id to consider
  #   params  - used to handle a special case: if the list of cta has been constructed by filtering the start/end date of ical interactions,
  #             ctas with multiple icals will be duplicated; after full processing each duplicate will contain just one of the initial ical interactions;
  #             this method has to ensure that only the ical interactions that have been considered by the query that obtained the ctas are included
  #             in the result Hash.
  def get_cta_to_interactions_map(cta_ids, params = {})
    cta_to_interactions = {}
    interactions = Interaction.includes(:resource).where("call_to_action_id IN (?)", cta_ids).references(:resources)
    if params.include?(:ical_start_datetime) || params.include?(:ical_end_datetime)
      interactions = interactions.joins("LEFT OUTER JOIN downloads ON downloads.id = interactions.resource_id")
      interactions = add_ical_fields_to_where_condition(interactions, params, true)
      # TODO: order_string has been thought for get_ctas_with_tags_in_XXX(), it might break here!
      if params[:order_string]
        interactions = interactions.order("cast(\"ical_fields\"->'start_datetime'->>'value' AS timestamp) ASC")
      end
    end
    interactions.each do |inter|
      (cta_to_interactions[inter.call_to_action_id] ||= []) << {
        interaction_info: inter,
        interaction_resource: inter.resource
      }
    end
    cta_to_interactions
  end

  # This method implement a nasty workaround to handle multiple download-iCal interactions: a download-iCal interaction
  # is tipically shown with a small date/time graphics in the content preview, but when a CTA has more than one iCal,
  # the amount of information to display is too heavy. Moreover, a CTA with multiple iCals might be shown multiple
  # times in a stripe (for example when the stripe is sorted by ical date).
  # The chosen solution is to display in the content preview a different iCal everytime the same CTA is displayed in a stripe.
  def get_interactions_from_cta_to_interaction_map(cta_id_to_interactions, cta_id)
    interactions = cta_id_to_interactions[cta_id]
    if interactions.nil?
      nil
    else
      download_ical_interactions, other_interactions = interactions.partition do |interaction|
        interaction[:interaction_info].resource_type == 'Download' && interaction[:interaction_resource].ical?
      end

      if download_ical_interactions.any?
        a_download_ical_interaction = download_ical_interactions.shift
        cta_id_to_interactions[cta_id] = download_ical_interactions + other_interactions
        other_interactions + [a_download_ical_interaction]
      else
        other_interactions
      end
    end
  end
  
end
