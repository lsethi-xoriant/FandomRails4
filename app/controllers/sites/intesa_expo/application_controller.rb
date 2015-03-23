class Sites::IntesaExpo::ApplicationController < ApplicationController
  include RewardHelper
  include RankingHelper
  include IntesaExpoHelper
  
  def index
    if current_user
      compute_save_and_notify_context_rewards(current_user)
    end

    return if cookie_based_redirect?

    if $context_root == "imprese"
      @aux_other_params = {
        "calltoaction_evidence_info" => true,
        "next-live_stripe" => get_intesa_expo_ctas_with_tag("next-live"),
        "gallery_stripe" => get_intesa_expo_ctas_with_tag("gallery"),
        "interview_stripe" => get_intesa_expo_ctas_with_tag("interview"),
        "story_stripe" => get_intesa_expo_ctas_with_tag("story"),
        "enterprise-in-evidence_stripe" => get_intesa_expo_ctas_with_tag("enterprise-in-evidence"),
        page_tag: {
          miniformat: {
            name: "imprese-home"
          }
        }
      }
      render template: "/application/imprese_index"
    else
      @aux_other_params = {
        calltoaction_evidence_info: true,
        "next-live_stripe" => get_intesa_expo_ctas_with_tag("next-live"),
        "gallery_stripe" => get_intesa_expo_ctas_with_tag("gallery"),
        "article_stripe" => get_intesa_expo_ctas_with_tag("article"),
        page_tag: {
          miniformat: {
            name: "home"
          }
        }
      }
    end
  end

  def about
    language = $context_root || "it"
    cta = CallToAction.find("about-#{language}")

    @calltoaction_info_list = build_call_to_action_info_list([cta])
  end

end