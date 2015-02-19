
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def ordering_ctas
    if params["other_params"] && (other_params = JSON.parse(params["other_params"])["gallery"]["calltoaction_id"])
      gallery_calltoaction_id = other_params
    end

    property = get_tag_from_params(get_disney_property())
    init_ctas = $site.init_ctas

    calltoactions = []
    ordering = params["ordering"]

    case ordering
    when "comment"
      calltoactions = cache_short(get_calltoactions_in_property_by_ordering_cache_key(property.id, ordering, gallery_calltoaction_id)) do
        calltoaction_ids = get_disney_ctas(property, gallery_calltoaction_id).map { |calltoaction| calltoaction.id }.join(",")
        sql = "SELECT call_to_actions.id,  sum((user_comment_interactions.approved is not null and user_comment_interactions.approved)::integer) " +
              "FROM call_to_actions LEFT OUTER JOIN interactions ON call_to_actions.id = interactions.call_to_action_id LEFT OUTER JOIN user_comment_interactions ON interactions.resource_id = user_comment_interactions.comment_id " +
              "WHERE interactions.resource_type = 'Comment' AND call_to_actions.id in (#{calltoaction_ids}) " +
              "GROUP BY call_to_actions.id " +
              "ORDER BY sum DESC limit #{init_ctas};"
        execute_sql_and_get_ctas_ordered(sql)
      end
    when "view"
      calltoactions = cache_short(get_calltoactions_in_property_by_ordering_cache_key(property.id, ordering, gallery_calltoaction_id)) do
        calltoaction_ids = get_disney_ctas(property, gallery_calltoaction_id).map { |calltoaction| calltoaction.id }.join(",")
        sql = "SELECT call_to_actions.id " +
              "FROM call_to_actions LEFT OUTER JOIN view_counters ON call_to_actions.id = view_counters.ref_id " +
              "WHERE (view_counters.ref_type is null OR view_counters.ref_type = 'cta') AND call_to_actions.id in (#{calltoaction_ids}) " +
              "ORDER BY (coalesce(view_counters.counter, 0) / (extract('epoch' from (now() - coalesce(call_to_actions.activated_at, call_to_actions.created_at) )) / 3600 / 24)), call_to_actions.activated_at DESC limit #{init_ctas};"
        execute_sql_and_get_ctas_ordered(sql)
      end
    else
      calltoactions = cache_medium(get_calltoactions_in_property_cache_key(property.id, gallery_calltoaction_id, get_cta_max_updated_at())) do
        get_disney_ctas(property, gallery_calltoaction_id).limit(init_ctas).to_a
      end
    end

    response = {
      calltoaction_info_list: build_call_to_action_info_list(calltoactions, ["like", "comment", "share"])
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end 
  end

  def execute_sql_and_get_ctas_ordered(sql)
    cta_ids = ActiveRecord::Base.connection.execute(sql)
    order =  cta_ids.map { |r| "call_to_actions.id = #{r["id"].to_i} DESC" }
    CallToAction.where("call_to_actions.id IN (?)", cta_ids.map { |r| r["id"].to_i }).order("#{order.join(",")}").to_a
  end

  def build_current_user() 
    build_disney_current_user()
  end

  def check_profanity_words(text)

    user_comment_text = text.downcase
    @profanities_regexp = cache_short(get_profanity_words_cache_key("disney")) do
      pattern_array = Array.new

      profanity_words = Setting.find_by_key("profanity.words")
      if profanity_words
        profanity_words.value.split(",").each do |exp|
          pattern_array.push(build_regexp(exp))
        end
      end
      Regexp.union(pattern_array)
    end

    user_comment_text =~ @profanities_regexp
  end

  def build_regexp(line)
    string = "(\\W+|^)"
    line.strip.each_char do |c|
      if REGEX_SPECIAL_CHARS.include? c
        c = "\\" + c
      end
      if c != " "
        string += "(\\W*)" + c
      end
    end
    Regexp.new(string)
  end

  def add_comment
    interaction = Interaction.find(params[:interaction_id])
    comment_resource = interaction.resource

    must_be_approved = comment_resource.must_be_approved
    approved = must_be_approved == false ? true : nil
    user_text = params[:comment_info][:user_text]
    profanity_filter_automatic_setting = Setting.find_by_key('profanity.filter.automatic')
    apply_profanity_filter_automatic = profanity_filter_automatic_setting.nil? ? false : (profanity_filter_automatic_setting.value == "true")

    if apply_profanity_filter_automatic
      has_profanities = check_profanity_words(user_text)
      aux = has_profanities ? { "profanity" => true }.to_json : "{}"
      approved = false if has_profanities
    else
      aux = "{}"
    end
    
    response = Hash.new

    response[:approved] = must_be_approved

    response[:ga] = Hash.new
    response[:ga][:category] = "UserCommentInteraction"
    response[:ga][:action] = "AddComment"

    if current_user
      user_comment = UserCommentInteraction.new(user_id: current_user.id, approved: approved, text: user_text, comment_id: comment_resource.id, aux: aux)
      user_comment.save
      response[:comment] = build_comment_for_comment_info(user_comment, true)
      if approved && user_comment.errors.blank?
        user_interaction, outcome = create_or_update_interaction(current_user, interaction, nil, nil)
        expire_cache_key(get_comments_approved_cache_key(interaction.id))
      end
    else
      captcha_enabled = get_deploy_setting("captcha", true)
      response[:captcha] = captcha_enabled
      response[:captcha_evaluate] = !captcha_enabled || params[:session_storage_captcha] == Digest::MD5.hexdigest(params[:comment_info][:user_captcha] || "")
      if response[:captcha_evaluate]
        user_comment = UserCommentInteraction.new(user_id: current_or_anonymous_user.id, approved: approved, text: user_text, comment_id: comment_resource.id)
        user_comment.save unless check_profanity_words_in_comment(user_comment).errors.any?
        response[:comment] = build_comment_for_comment_info(user_comment, true)
        if approved && user_comment.errors.blank?
          user_interaction, outcome = create_or_update_interaction(user_comment.user, interaction, nil, nil)
          expire_cache_key(get_comments_approved_cache_key(interaction.id))
        end
      end
      response[:captcha] = generate_captcha_response
    end

    if user_comment && user_comment.errors.any?
      response[:errors] = user_comment.errors.full_messages.join(", ")
    end

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end

  def get_context()
    get_disney_property()
  end

  def init_show_aux(calltoaction)
    @aux_other_params = { 
      init_captcha: true,
      calltoaction: calltoaction,
      sidebar_tags: ["detail"]
    }
  end

  def expire_user_interaction_cache_keys()
    if current_user
      current_property = get_tag_from_params(get_disney_property())
      expire_cache_key(get_evidence_calltoactions_in_property_for_user_cache_key(current_user.id, current_property.id))
    end
  end

  def send_share_interaction_email(address, calltoaction)
    property = get_tag_from_params(get_disney_property())
    aux = {
      color: get_extra_fields!(property)["label-background"],
      logo: (get_extra_fields!(property)["logo"]["url"] rescue nil),
      path: compute_property_path(property),
      root: root_url,
      subject: property.title
    }
    SystemMailer.share_interaction(current_user, address, calltoaction, aux).deliver
  end

  def append_calltoaction
    page_elements = ["like", "comment", "share"]

    if params["other_params"] && params["other_params"]["gallery"]["calltoaction_id"]
      gallery_calltoaction_id = params["other_params"]["gallery"]["calltoaction_id"]
      page_elements = page_elements + ["vote"]
    end

    calltoaction_ids_shown = params[:calltoaction_ids_shown]
    calltoaction_ids_shown_qmarks = (["?"] * calltoaction_ids_shown.count).join(", ")

    property = get_tag_from_params(get_disney_property())

    ordering = params[:ordering]

    response = cache_short(get_next_ctas_stream_for_user_cache_key(current_or_anonymous_user.id, property.id, calltoaction_ids_shown.last, get_cta_max_updated_at(), ordering, gallery_calltoaction_id)) do
      calltoactions = cache_short(get_next_ctas_stream_cache_key(property.id, calltoaction_ids_shown.last, get_cta_max_updated_at(), ordering, gallery_calltoaction_id)) do     
        calltoactions = get_disney_ctas(property, gallery_calltoaction_id).where("call_to_actions.id NOT IN (#{calltoaction_ids_shown_qmarks})", *calltoaction_ids_shown)
        case ordering
        when "comment"
          calltoaction_ids = calltoactions.map { |calltoaction| calltoaction.id }.join(",")
          sql = "SELECT call_to_actions.id, sum((user_comment_interactions.approved is not null and user_comment_interactions.approved)::integer) " +
                "FROM call_to_actions LEFT OUTER JOIN interactions ON call_to_actions.id = interactions.call_to_action_id LEFT OUTER JOIN user_comment_interactions ON interactions.resource_id = user_comment_interactions.comment_id " +
                "WHERE interactions.resource_type = 'Comment' AND call_to_actions.id in (#{calltoaction_ids}) " +
                "GROUP BY call_to_actions.id " +
                "ORDER BY sum DESC limit 4;"
          execute_sql_and_get_ctas_ordered(sql)
        when "view"
          calltoaction_ids = calltoactions.map { |calltoaction| calltoaction.id }.join(",")
          sql = "SELECT call_to_actions.id " +
              "FROM call_to_actions LEFT OUTER JOIN view_counters ON call_to_actions.id = view_counters.ref_id " +
              "WHERE (view_counters.ref_type is null OR view_counters.ref_type = 'cta') AND call_to_actions.id in (#{calltoaction_ids}) " +
              "ORDER BY (coalesce(view_counters.counter, 0) / (extract('epoch' from (now() - coalesce(call_to_actions.activated_at, call_to_actions.created_at) )) / 3600 / 24)), call_to_actions.activated_at DESC limit 4;"
        else
          calltoactions = calltoactions.limit(4).to_a
        end
        calltoactions
      end
      
      {
        calltoaction_info_list: build_call_to_action_info_list(calltoactions, page_elements)
      }.to_json
    end
    
    respond_to do |format|
      format.json { render json: response }
    end 
  end
  
  def upload
    upload_interaction = Interaction.find(params[:interaction_id]).resource
    cloned_cta = create_user_calltoactions(upload_interaction)
    calltoaction = CallToAction.find(params[:cta_id])
    
    if cloned_cta.errors.any?
      flash[:error] = cloned_cta.errors.full_messages.join(", ")
    else
      flash[:notice] = "Caricamento completato con successo"
    end

    if is_call_to_action_gallery(calltoaction)
      redirect_to "/gallery/#{params[:cta_id]}"
    else
      redirect_to "/call_to_action/#{params[:cta_id]}"
    end
    
  end
  
  def create_user_calltoactions(upload_interaction)
    cloned_cta = clone_and_create_cta(upload_interaction, params, upload_interaction.watermark)
    cloned_cta.build_user_upload_interaction(user_id: current_user.id, upload_id: upload_interaction.id)
    cloned_cta.save
    cloned_cta
  end

end