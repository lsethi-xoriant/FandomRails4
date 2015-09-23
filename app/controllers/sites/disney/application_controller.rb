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

    tag_name = get_disney_property()
    params = { "page_elements" => ["like", "comment", "share"] }
    @calltoaction_info_list, @has_more = get_ctas_for_stream(tag_name, params, $site.init_ctas)
    
    @aux_other_params = { 
      filters: true,
      calltoaction_evidence_info: false,
      sidebar_tag: "sidebar-home"
    }

  end
  
end