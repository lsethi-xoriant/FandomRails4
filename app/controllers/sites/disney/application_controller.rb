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
    
    #cache_key = property.id
    #cache_timestamp = get_cta_max_updated_at()

    #@calltoactions = cache_forever(get_ctas_cache_key(cache_key, cache_timestamp)) do
    #  get_disney_ctas(property).limit(init_ctas).to_a
    #end

    @calltoaction_info_list = get_disney_ctas_for_stream({}, $site.init_ctas)

    @aux_other_params = { 
      filters: true,
      calltoaction_evidence_info: false,
      sidebar_tags: ["stream"],
      fan_of_the_day_widget: true,
      rank_widget: true,
      ctas_most_viewed_widget: get_ctas_most_viewed_widget()
    }

  end

  def build_current_user() 
    build_disney_current_user()
  end
  
end