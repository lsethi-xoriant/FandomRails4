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
          "enterprise-in-evidence_stripe" => get_intesa_expo_ctas_with_tag("enterprise-in-evidence")
        }
      end

      @aux_other_params = {
        calltoaction_evidence_info: true,
        "event_stripe" => home_stripes["event_stripe"],
        "gallery_stripe" => home_stripes["gallery_stripe"],
        "interview_stripe" => home_stripes["interview_stripe"],
        "story_stripe" => home_stripes["story_stripe"],
        "article_stripe" => home_stripes["article_stripe"],
        "tag_menu_item" => "imprese-home"
      }
      render template: "/application/imprese_index"

    else

      home_stripes = cache_short(get_home_stripes_cache_key($context_root || "it")) do
        if $context_root == "en"
          story_stripe = get_intesa_expo_ctas_with_tag("story")
        end
        {
          "event_stripe" => get_intesa_expo_ctas_with_tag("event"),
          "gallery_stripe" => get_intesa_expo_ctas_with_tag("gallery"),
          "story_innovation_stripe" => get_intesa_expo_ctas_with_tag("story-innovation"),
          "press_stripe" => get_intesa_expo_ctas_with_tag("press"),
          "article_stripe" => get_intesa_expo_ctas_with_tag("article"),
          #"press-release_stripe" => get_intesa_expo_ctas_with_tag("press-release"),
          "story_stripe" => story_stripe
        }
      end

      @aux_other_params = {
        calltoaction_evidence_info: true,
        "event_stripe" => home_stripes["event_stripe"],
        "article_stripe" => home_stripes["article_stripe"],
        "gallery_stripe" => home_stripes["gallery_stripe"],
        "story_innovation_stripe" => home_stripes["story_innovation_stripe"],
        "press_stripe" => home_stripes["press_stripe"],
        "story_stripe" => home_stripes["story_stripe"],
        #"press-release_stripe" => home_stripes["press-release_stripe"],
        "tag_menu_item" => "home"
      }

    end
  end

  def live
    language_tag = get_tag_from_params($context_root || "it")
    live_tag = get_tag_from_params("live")

    #cta = get_ctas_with_tags_in_and([language_tag.id, live_tag.id])[0]

    tag_ids = [live_tag.id, language_tag.id]
    tag_ids_subselect = tag_ids.map { |tag_id| "(select call_to_action_id from call_to_action_tags where tag_id = #{tag_id})" }.join(' INTERSECT ')
    cta = CallToAction.includes(call_to_action_tags: :tag).joins("JOIN interactions ON interactions.call_to_action_id = call_to_actions.id")
                .joins("JOIN downloads ON downloads.id = interactions.resource_id AND interactions.resource_type = 'Download'")
                .where("call_to_actions.id IN (#{tag_ids_subselect})")
                .order("cast(\"ical_fields\"->'start_datetime'->>'value' AS timestamp) ASC")
                .first

    @calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at([cta])
    complete_cta_for_show(cta)

    @aux_other_params[:tag_menu_item] = "live"

    render template: "/call_to_action/show"
  end

  def about
    language = $context_root || "it"
    cta = CallToAction.find("about-#{language}")

    @calltoaction_info_list = build_cta_info_list_and_cache_with_max_updated_at([cta])

    complete_cta_for_show(cta)

    @aux_other_params[:tag_menu_item] = get_extra_fields!(cta)["menu_item"]
  end

  def complete_cta_for_show(calltoaction)
    @aux_other_params = { 
      calltoaction: calltoaction
    }

    calltoaction_to_share = calltoaction
    calltoaction_to_share_title = strip_tags(calltoaction_to_share.title) || ""
    calltoaction_to_share_description = strip_tags(calltoaction_to_share.description) || ""
    calltoaction_to_share_thumbnail = calltoaction_to_share.thumbnail.url rescue ""

    @fb_meta_tags = (
        '<meta property="og:type" content="article" />' +
        '<meta property="og:locale" content="it_IT" />' +
        '<meta property="og:title" content="' + calltoaction_to_share_title + '" />' +
        '<meta property="og:description" content="' + calltoaction_to_share_description + '" />' +
        '<meta property="og:image" content="' + calltoaction_to_share_thumbnail + '" />'
      ).html_safe

    set_seo_info_for_cta(calltoaction)
  end

end