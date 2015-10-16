require "test_helper"

class ProfileTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    @ignore_hidden_elements_option = Capybara.ignore_hidden_elements
    Capybara.ignore_hidden_elements = false
    @user_email = build_new_user_email
  end

  test "user registration and editing" do

    # Registration and notifications

    visit(build_url_for_capybara("/users/sign_up"))

    within("form[action='/users']") do
      fill_in "user_first_name", :with => "John"
      fill_in "user_last_name", :with => "Doe"
      fill_in "user_email", :with => @user_email
      fill_in "user_password", :with => "shado00"
      fill_in "user_password_confirmation", :with => "shado00"
      check("user_privacy")
      first("button", :text => "Registrati").click
    end

    wait_for_ajax

    user_first_name = first("p[class^='properties__right-bar-text']").text
    assert user_first_name[0..3] == "John", "User name is not \"John D.\", but \"#{user_first_name}\""

    notices_link = first("a[ng-href='/profile/notices']")
    assert notices_link.text.to_i > 0, "User has no notice after registration"
    notices_link.click

    within("div.section-heading") do
      page_title = first("h3").text
      assert page_title == "Notifiche", "Page title is \"#{page_title}\" instead of \"Notifiche\""
    end

    visit_home

    first("img[ng-if='!isAnonymousUser()']").click
    profile_url = current_url
    first("a", :text => "Profilo").click
    assert current_url == profile_url, "After secondary menu profile link click, redirected to #{current_url} instead of #{profile_url}"

    within("div.profile-header__item--level") do
      level = first("p.profile-header__item__title").text
      assert level == "Livello 2 All", "Level in profile page should be \"Livello 2 All\", but it is \"#{level}\""
    end

    # Name editing

    assert assert_selector("input#user_first_name"), "User first name input is not present"
    assert assert_selector("input#user_last_name"), "User last name input is not present"
    fill_in "user_first_name", :with => "Joe"
    fill_in "user_last_name", :with => "Bloggs"
    first("button", :text => "SALVA").click

    assert assert_selector("div.alert"), "No alert present after changing user full name"
    assert first("div.alert")[:class].include?("alert-success"), "No success alert rendered after changing user full name"

    # Rewards -> Levels

    first("a", :text => "Rewards").click
    wait_for_angular
    wait_for_ajax
    check_progress_bar_width_for_level("level-1", "== 100")
    for i in 2..5
      check_progress_bar_width_for_level("level-#{i}", "== 0")
    end

    visit(build_url_for_capybara("/call_to_action/qual-la-canzone-pi-romantica-della-discografia-dei-coldplay")) # just to take a couple of points
    page.first("button.like-interaction__cover__info__button").click
    wait_for_angular
    go_back
    reload_page

    check_progress_bar_width_for_level("level-2", "> 0")

  end

  teardown do
    Capybara.ignore_hidden_elements = @ignore_hidden_elements_option
  end

  def build_new_user_email
    "test_#{DateTime.now.strftime("%Y_%m_%d_%H_%M_%S")}@example.com"
  end

  def check_progress_bar_width_for_level(text, cond)
    parent_div = first("h4", :text => text).first(:xpath, ".//..")
    within(parent_div) do
      @perc = first("div.progress-bar")[:style].gsub("width: ", "").gsub("\%\;", "")
    end
    assert eval(@perc + cond), "Progress for #{text} should be #{cond}% instead of #{@perc}%"
  end

end