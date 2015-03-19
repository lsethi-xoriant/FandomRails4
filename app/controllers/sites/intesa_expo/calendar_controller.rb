class Sites::IntesaExpo::ApplicationController < ApplicationController
  include RewardHelper
  include RankingHelper
  include OrzoroHelper
  include IntesaExpoHelper
  
  def index
    if current_user
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?
    
    @calltoaction_info_list = {}

    @aux_other_params = { 
      calltoaction_evidence_info: true,
      next_live: true,
      page_tag: {
        miniformat: {
          name: "home"
        }
      }
    }
  end

end