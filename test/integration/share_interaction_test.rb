require "test_helper"

class ShareInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "share interaction" do

    cta_link = login_and_find_call_to_action_with_title("Qual è la canzone più romantica della discografia dei Coldplay?")

    delete_user_interactions

    visit(cta_link)

    # Direct url
    first("span[class='fa fa-share-alt']").first(:xpath, "..").click

    wait_for_ajax

    assert_selector("div[id$='-share-modal']")

    delete_user_interactions

    perform_logout

  end

end