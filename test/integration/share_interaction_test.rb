require "test_helper"

class ShareInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "share interaction" do

    cta_link = login_and_find_call_to_action_with_title("Cta with share interaction")

    delete_user_interactions

    visit(cta_link)

    # Direct url
    assert assert_no_selector("div[id$='-direct_url']"), "Direct url share div is present before click"
    find("button[ng-if$='.direct_url']").click
    assert assert_selector("div[id$='-direct_url']"), "Direct url share div is not present after click"

    # Email
    assert assert_no_selector("div[id$='-email']"), "Email share div is present before click"
    find("button[ng-if$='.email']").click
    assert assert_selector("div[id$='-email']"), "Email share div is not present after click"

    delete_user_interactions

    perform_logout

  end

end