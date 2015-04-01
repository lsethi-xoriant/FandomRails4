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

      home_stripes = cache_short(get_home_stripes_cache_key($context_root)) do
        {
          "event_stripe" => get_intesa_expo_ctas_with_tag("event"),
          "gallery_stripe" => get_intesa_expo_ctas_with_tag("gallery"),
          "interview_stripe" => get_intesa_expo_ctas_with_tag("interview"),
          "story_stripe" => get_intesa_expo_ctas_with_tag("story"),
          "enterprise-in-evidence_stripe" => get_intesa_expo_ctas_with_tag("enterprise-in-evidence"),
        }
      end

      @aux_other_params = {
        calltoaction_evidence_info: true,
        "event_stripe" => home_stripes["event_stripe"],
        "gallery_stripe" => home_stripes["gallery_stripe"],
        "interview_stripe" => home_stripes["interview_stripe"],
        "story_stripe" => home_stripes["story_stripe"],
        "enterprise-in-evidence_stripe" => home_stripes["enterprise-in-evidence_stripe"],
        page_tag: {
          miniformat: {
            name: "imprese-home"
          }
        }
      }
      render template: "/application/imprese_index"

    else

      home_stripes = cache_short(get_home_stripes_cache_key($context_root || "it")) do
        {
          "event_stripe" => get_intesa_expo_ctas_with_tag("event"),
          "gallery_stripe" => get_intesa_expo_ctas_with_tag("gallery"),
          "article_stripe" => get_intesa_expo_ctas_with_tag("article")
        }
      end

      @aux_other_params = {
        calltoaction_evidence_info: true,
        "event_stripe" => home_stripes["event_stripe"],
        "gallery_stripe" => home_stripes["gallery_stripe"],
        "article_stripe" => home_stripes["article_stripe"],
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