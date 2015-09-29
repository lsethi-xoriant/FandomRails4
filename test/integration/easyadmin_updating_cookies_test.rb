require "test_helper"

class EasyadminUpdatingCookies < ActionController::TestCase

  include Devise::TestHelpers
  include EasyadminHelper

  setup do
    initialize_tenant
  end

  test "content updated at cookie" do

    delete_updating_content_cookies()
    assert get_content_updated_at_cookie().nil?, "content_updated_at cookie is not nil"

    tag = Tag.where(:name => "sample-tag").first
    tag_2 = Tag.where(:name => "sample-tag-2").first

    tag_updated_at = tag.updated_at
    tag_2_updated_at = tag_2.updated_at

    admin_login

    visit(build_url_for_capybara("/easyadmin/cta"))
    fill_in "title_filter", :with => "Cta to update"
    page.find("input[value='APPLICA FILTRO']").click

    within("table") do
      first("a[href^='/easyadmin/cta/edit/']").click
    end

    activation_date_time = find_field("call_to_action[activation_date_time]").value
    activation_date_time[-1] = ((activation_date_time[-1].to_i + 1) % 10).to_s
    fill_in "call_to_action[activation_date_time]", :with => activation_date_time
    page.find("button", :text => "AGGIORNA").click

    find_and_click_update_cache_button

    perform_logout

  end

  test "moderation cookie" do

    delete_updating_content_cookies()
    assert get_content_updated_at_cookie().nil?, "content_updated_at cookie is not nil"

    admin_login

    visit(build_url_for_capybara("/easyadmin/cta/to_approve"))
    fill_in "title_filter", :with => "User cta to update"
    page.find("input[value='FILTRA']").click
    page.find("button[onclick^='updateCta(false,']").click

    wait_for_ajax

    visit(build_url_for_capybara("/easyadmin/cta/to_approve"))

    find_and_click_update_cache_button

    user_cta = CallToAction.where(:name => "user-cta-to-update").first
    user_cta.update_attribute(:approved, nil)

    perform_logout

  end

  def find_and_click_update_cache_button
    Capybara.ignore_hidden_elements = false
    assert_not page.find("div#update-cache-banner")[:class].include?("hidden"), "After cta update, cookie banner is hidden"
    page.find("button[onclick='updateUpdatedAt()']").click
    wait_for_ajax
    reload_page
    assert page.find("div#update-cache-banner")[:class].include?("hidden"), "After cookie button click, cookie banner is not hidden"
    wait_for_ajax
  end

  def set_updated_at(instance, time)
    instance.class.record_timestamps = false
    instance.update_attribute(:updated_at, time)
    instance.class.record_timestamps = true
  end

end