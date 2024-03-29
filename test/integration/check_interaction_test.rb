require "test_helper"

class CheckInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "check interaction" do

    login_and_find_call_to_action_with_title("Qual è la canzone più romantica della discografia dei Coldplay?", true)

    points = get_user_points_from_single_call_to_action_page

    verify_done_label_presence("check-undervideo-interaction__row", false)

    within("div.check-interaction__container") do
      page.first("a[ng-click^='updateAnswer']").click
    end

    verify_done_label_presence("check-undervideo-interaction__row", true)

    assert get_user_points_from_single_call_to_action_page > points, "No point given for check interaction done"

    delete_user_interactions

    perform_logout

  end

end