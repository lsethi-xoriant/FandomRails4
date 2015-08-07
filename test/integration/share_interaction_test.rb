require "test_helper"

class ShareInteraction < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "share interaction" do

    cta_link = call_to_action_with_title("Cta with share interaction")

    delete_user_interactions

    visit(cta_link)

    # starting_points = get_user_points_from_single_call_to_action_page

    # Direct url
    assert assert_no_selector("div[id$='-direct_url']"), "Direct url share div is present before click"
    find("button[ng-if$='.direct_url']").click
    assert assert_selector("div[id$='-direct_url']"), "Direct url share div is not present after click"

    #Email
    assert assert_no_selector("div[id$='-email']"), "Email share div is present before click"
    find("button[ng-if$='.email']").click
    assert assert_selector("div[id$='-email']"), "Email share div is not present after click"

    # new_points = get_user_points_from_single_call_to_action_page
    # assert new_points > starting_points, "No point given like interaction"

    delete_user_interactions

    admin_logout

  end

end