require "test_helper"

class LikeInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "like interaction" do

    cta_link = login_and_find_call_to_action_with_title("Qual è la canzone più romantica della discografia dei Coldplay?")

    visit(cta_link)
    starting_likes = first("span.like-interaction__cta__info__text").text.gsub(" mi piace", "").to_i
    starting_points = get_user_points_from_single_call_to_action_page()

    page.first("button.like-interaction__cover__info__button").click

    wait_for_angular

    new_likes = first("span.like-interaction__cta__info__text").text.gsub(" mi piace", "").to_i
    new_points = get_user_points_from_single_call_to_action_page()

    assert new_likes = starting_likes + 1, "Like counter should have been raised to #{starting_likes + 1}, but is #{new_likes}"
    assert new_points > starting_points, "No point given for like interaction"

    delete_user_interactions

    perform_logout

  end

end