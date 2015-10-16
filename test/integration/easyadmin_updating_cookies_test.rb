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

    admin_login

    old_activation_date_time = change_cta_activated_at()

    find_and_click_update_cache_button
    wait_for_ajax

    old_activation_date_time = change_cta_activated_at(old_activation_date_time)
    perform_logout

  end

  test "moderation cookie" do

    delete_updating_content_cookies()
    assert get_content_updated_at_cookie().nil?, "content_updated_at cookie is not nil"

    admin_login

    visit(build_url_for_capybara("/easyadmin/cta/approved"))

    user_cta_slug = within(page.first("tr[id^='cta-']")) do
      page.all("td")[1].text
    end

    page.first("button[onclick^='updateCta(false,']").click

    wait_for_ajax

    visit(build_url_for_capybara("/easyadmin/cta/approved"))

    find_and_click_update_cache_button

    visit(build_url_for_capybara("/easyadmin/cta/not_approved"))
    fill_in "slug_filter", :with => user_cta_slug
    page.find("input[value='FILTRA']").click
    wait_for_ajax
    page.first("button[onclick^='updateCta(true,']").click

    perform_logout

  end

  def find_and_click_update_cache_button
    Capybara.ignore_hidden_elements = false
    assert_not page.find("div#update-cache-banner")[:class].include?("hidden"), "After cta update, cookie banner is hidden"
    page.first("button[onclick='updateUpdatedAt()']").click
    wait_for_ajax
    reload_page
    assert page.first("div#update-cache-banner")[:class].include?("hidden"), "After cookie button click, cookie banner is not hidden"
    wait_for_ajax
  end

  def change_cta_activated_at(new_activation_date_time = nil)
    visit(build_url_for_capybara("/easyadmin/cta"))
    fill_in "title_filter", :with => "Qual è la canzone più romantica della discografia dei Coldplay?"
    page.first("input[value='APPLICA FILTRO']").click

    within("table") do
      first("a[href^='/easyadmin/cta/edit/']").click
    end

    old_activation_date_time = find_field("call_to_action[activation_date_time]").value
    if !new_activation_date_time
      new_activation_date_time = old_activation_date_time
      new_activation_date_time[-1] = ((new_activation_date_time[-1].to_i + 1) % 10).to_s
    end
    fill_in "call_to_action[activation_date_time]", :with => new_activation_date_time
    page.first("button", :text => "AGGIORNA").click
    old_activation_date_time
  end

  def set_updated_at(instance, time)
    instance.class.record_timestamps = false
    instance.update_attribute(:updated_at, time)
    instance.class.record_timestamps = true
  end

end