require "test_helper"

class CheckInteraction < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "check interaction" do

    call_to_action_with_title("Cta with check interaction", true)

    points = get_user_points_from_single_call_to_action_page

    assert has_no_field?("span.label-success"), "Success span is in page, but it shouldn't be"

    within("div.check-interaction__container") do
      page.find("a[ng-click^='updateAnswer']").click
    end

    wait_for_angular

    assert get_user_points_from_single_call_to_action_page > points, "No point given for check interaction done"

    delete_user_interactions

    admin_logout

  end

end