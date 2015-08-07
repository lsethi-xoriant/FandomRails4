require "test_helper"

class LikeInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "like interaction" do

    cta_link = call_to_action_with_title("Cta with like interaction")

    visit(cta_link)
    starting_points = get_user_points_from_single_call_to_action_page

    page.find("button.like-interaction__cover__info__button").click

    wait_for_angular

    new_points = get_user_points_from_single_call_to_action_page
    assert new_points > starting_points, "No point given for like interaction"

    delete_user_interactions

    admin_logout

  end

end