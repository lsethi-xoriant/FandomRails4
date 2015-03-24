class Sites::Disney::ApplicationController < ApplicationController
  include RewardHelper
  include RankingHelper
  include DisneyHelper

  def iur
    referrer = request.referrer 
    begin
      if URI.parse(request.referrer).path != "/iur" && URI.parse(request.referrer).path != "/iur/sign_in"
        cookies[:from_iur_authenticate] = referrer
      end
    rescue Exception => e
      cookies[:from_iur_authenticate] = "/"
    end
    render layout: false
  end
  
  def index
    if current_user
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?
    
    init_ctas = $site.init_ctas
    property = get_tag_from_params(get_disney_property())

    @calltoactions = cache_medium(get_calltoactions_in_property_cache_key(property.id, 0, get_cta_max_updated_at())) do
      get_disney_ctas(property).limit(init_ctas).to_a
    end

    @calltoaction_info_list = build_call_to_action_info_list(@calltoactions, ["like", "comment", "share"])

    @aux_other_params = { 
      filters: true,
      calltoaction_evidence_info: false,
      sidebar_tags: ["stream"],
      fan_of_the_day_widget: true,
      ctas_most_viewed_widget: get_ctas_most_viewed_widget(property)
    }

  end

  def build_current_user() 
    build_disney_current_user()
  end
  
end