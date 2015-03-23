class Sites::IntesaExpo::ApplicationController < ApplicationController
  include RewardHelper
  include RankingHelper
  include IntesaExpoHelper
  
  def index
    if current_user
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?
    
    @calltoaction_info_list = {}

    @aux_other_params = {
      calltoaction_evidence_info: true,
      home: true,
      page_tag: {
        miniformat: {
          name: "home"
        }
      }
    }
  end

  def about
    language = $context_root || "it"
    cta = CallToAction.find("about-#{language}")

    @calltoaction_info_list = build_call_to_action_info_list([cta])
  end

end