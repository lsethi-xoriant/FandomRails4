
class Sites::Disney::CallToActionController < CallToActionController
  include DisneyHelper

  def ordering_ctas
    property = get_tag_from_params(get_disney_property())
    init_ctas = $site.init_ctas

    calltoactions = []
    ordering = params["ordering"]

    case ordering
    when "comment"
      calltoactions = cache_short(get_calltoactions_in_property_by_ordering_cache_key(property.id, ordering)) do
        calltoaction_ids = get_disney_ctas(property).map { |calltoaction| calltoaction.id }.join(",")
        sql = "SELECT call_to_actions.id,  sum((user_comment_interactions.approved is not null and user_comment_interactions.approved)::integer) " +
              "FROM call_to_actions LEFT OUTER JOIN interactions ON call_to_actions.id = interactions.call_to_action_id LEFT OUTER JOIN user_comment_interactions ON interactions.resource_id = user_comment_interactions.comment_id " +
              "WHERE interactions.resource_type = 'Comment' AND call_to_actions.id in (#{calltoaction_ids}) " +
              "GROUP BY call_to_actions.id " +
              "ORDER BY sum DESC limit #{init_ctas};"
        execute_sql_and_get_ctas_ordered(sql)
      end
    when "view"
      calltoactions = cache_short(get_calltoactions_in_property_by_ordering_cache_key(property.id, ordering)) do
        calltoaction_ids = get_disney_ctas(property).map { |calltoaction| calltoaction.id }.join(",")
        sql = "SELECT call_to_actions.id " +
              "FROM call_to_actions LEFT OUTER JOIN view_counters ON call_to_actions.id = view_counters.ref_id " +
              "WHERE (view_counters.ref_type is null OR view_counters.ref_type = 'cta') AND call_to_actions.id in (#{calltoaction_ids}) " +
              "ORDER BY (coalesce(view_counters.counter, 0) / (extract('epoch' from (now() - coalesce(call_to_actions.activated_at, call_to_actions.created_at) )) / 3600 / 24)), call_to_actions.activated_at DESC limit #{init_ctas};"
        execute_sql_and_get_ctas_ordered(sql)
      end
    else
      calltoactions = cache_short(get_calltoactions_in_property_cache_key(property.id)) do
        get_disney_ctas(property).limit(init_ctas).to_a
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

  def get_context()
    get_disney_property()
  end

  def init_show_aux(calltoaction)
    @aux_other_params = { 
      init_captcha: true,
      calltoaction: calltoaction
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
    calltoaction_ids_shown = params[:calltoaction_ids_shown]
    calltoaction_ids_shown_qmarks = (["?"] * calltoaction_ids_shown.count).join(", ")

    property = get_tag_from_params(get_disney_property())

    ordering = params[:ordering]

    response = cache_short(get_next_ctas_stream_for_user_cache_key(current_or_anonymous_user.id, property.id, calltoaction_ids_shown.last, get_cta_max_updated_at(), ordering)) do
      calltoactions = cache_short(get_next_ctas_stream_cache_key(property.id, calltoaction_ids_shown.last, get_cta_max_updated_at(), ordering)) do     
        calltoactions = get_disney_ctas(property).where("call_to_actions.id NOT IN (#{calltoaction_ids_shown_qmarks})", *calltoaction_ids_shown)
        case ordering
        when "comment"
          calltoaction_ids = calltoactions.map { |calltoaction| calltoaction.id }.join(",")
          sql = "SELECT call_to_actions.id, sum((user_comment_interactions.approved is not null and user_comment_interactions.approved)::integer) " +
                "FROM call_to_actions LEFT OUTER JOIN interactions ON call_to_actions.id = interactions.call_to_action_id LEFT OUTER JOIN user_comment_interactions ON interactions.resource_id = user_comment_interactions.comment_id " +
                "WHERE interactions.resource_type = 'Comment' AND call_to_actions.id in (#{calltoaction_ids}) " +
                "GROUP BY call_to_actions.id " +
                "ORDER BY sum DESC limit 3;"
          execute_sql_and_get_ctas_ordered(sql)
        when "view"
          calltoaction_ids = calltoactions.map { |calltoaction| calltoaction.id }.join(",")
          sql = "SELECT call_to_actions.id " +
              "FROM call_to_actions LEFT OUTER JOIN view_counters ON call_to_actions.id = view_counters.ref_id " +
              "WHERE (view_counters.ref_type is null OR view_counters.ref_type = 'cta') AND call_to_actions.id in (#{calltoaction_ids}) " +
              "ORDER BY (coalesce(view_counters.counter, 0) / (extract('epoch' from (now() - coalesce(call_to_actions.activated_at, call_to_actions.created_at) )) / 3600 / 24)), call_to_actions.activated_at DESC limit 3;"
        else
          calltoactions = calltoactions.limit(3).to_a
        end
        calltoactions
      end
      
      {
        calltoaction_info_list: build_call_to_action_info_list(calltoactions, ["like", "comment", "share"])
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