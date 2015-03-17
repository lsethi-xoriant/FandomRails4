class Sites::Orzoro::ApplicationController < ApplicationController
  include RewardHelper
  include RankingHelper
  include OrzoroHelper

  # Overridden from the base controller
  def cta_url(cta)
    orzoro_cta_url(cta)
  end
  
  def index
    if current_user
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?
    
    init_ctas = $site.init_ctas
     @calltoactions = cache_medium(get_calltoactions_in_property_cache_key(nil, 0, get_cta_max_updated_at())) do
      CallToAction.active.limit(init_ctas).to_a
    end

    @calltoaction_info_list = build_call_to_action_info_list(@calltoactions, ["empty"])

    @aux_other_params = { 
      calltoaction_evidence_info: true,
      page_tag: {
        miniformat: {
          name: "home"
        }
      }
    }

  end

  def faq
    
  end
  
  def netiquette
    
  end
  
end