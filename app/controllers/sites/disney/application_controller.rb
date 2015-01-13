class Sites::Disney::ApplicationController < ApplicationController
  include RewardHelper
  include RankingHelper
  include DisneyHelper

  def iur
    cookies[:from_iur_authenticate] = request.referrer
  end
  
  def index
    if current_user
      compute_save_and_notify_context_rewards(current_user)
      @current_user_info = build_current_user()
    end

    return if cookie_based_redirect?
    
    init_ctas = request.site.init_ctas
    current_property = get_tag_from_params(get_disney_property())

    @calltoactions = cache_short("stream_ctas_init_calltoactions_#{current_property}") do
      CallToAction.active.includes(:call_to_action_tags).where("call_to_action_tags.tag_id = ?", current_property.id).limit(init_ctas)
    end
    
    @calltoactions_during_video_interactions_second = cache_short("stream_ctas_init_calltoactions_during_video_interactions_second") do
      init_calltoactions_during_video_interactions_second(@calltoactions)
    end

    @calltoactions_comment_interaction = init_calltoactions_comment_interaction(@calltoactions)

    @calltoactions_active_count = cache_short("stream_ctas_init_calltoactions_active_count") do
      CallToAction.active.count
    end

    @calltoaction_info_list = build_call_to_action_info_list(@calltoactions)

    @aux = disney_default_aux(current_property)
  end

  def build_current_user() 
    build_disney_current_user()
  end
  
end