require "test_helper"

class RegistrationTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "registration" do

    user_email = build_new_user_email

    visit(build_url_for_capybara("/users/sign_up"))

    within("form[action='/users']") do
      fill_in "user_first_name", :with => "John"
      fill_in "user_last_name", :with => "Doe"
      fill_in "user_email", :with => user_email
      fill_in "user_password", :with => "shado00"
      fill_in "user_password_confirmation", :with => "shado00"
      check("user_privacy")
      find("button", :text => "Registrati").click
    end

    wait_for_ajax

    user_first_name = find("p[class^='properties__right-bar-text']").text[0..3]
    assert user_first_name == "John", "User name is not \"John\", but \"#{user_first_name}\""

    notices_link = find("a[ng-href='/profile/notices']")
    assert notices_link.text.to_i > 0, "User hasn't any notice after registration"
    notices_link.click

    within("div.section-heading") do
      page_title = find("h3").text
      assert page_title == "Notifiche", "Page title is \"#{page_title}\" instead of \"Notifiche\""
    end

    visit_home

    find("img[ng-if='!isAnonymousUser()']").click
    profile_url = current_url
    find("a", :text => "Profilo").click
    assert current_url == profile_url, "After secondary menu profile link click, redirected to #{current_url} instead of #{profile_url}"
    assert assert_selector("input#user_first_name"), "User first name input is not present"
    assert assert_selector("input#user_last_name"), "User last name input is not present"
    fill_in "user_first_name", :with => "Joe"
    fill_in "user_last_name", :with => "Bloggs"
    find("button", :text => "SALVA").click

    assert assert_selector("div.alert"), "No alert present after changing user full name"
    assert find("div.alert")[:class].include?("alert-success"), "No success alert rendered after changing user full name"


  end

  def build_new_user_email
    "test#{DateTime.now.strftime("%Y_%m_%d_%H_%M_%S")}@example.com"
  end

end