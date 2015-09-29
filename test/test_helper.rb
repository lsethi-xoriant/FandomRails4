ENV["RAILS_ENV"] = "test"

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'capybara/rails'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Make the Capybara DSL available in all integration tests
  include Capybara::DSL

  Capybara.default_driver = :selenium

  CORRECT_ANSWER = true
  INCORRECT_ANSWER = false

  CTA_TEST_NAME = "cta-for-user-interactions-testing"

  # Loads the seed file statements
  #
  # seed_name - Seed file name (without .rb extension
  # path - Path to the file, if different from "seeds"
  def load_seed(seed_name, path = "seeds")
    seed = open("#{File.dirname(__FILE__)}/#{path}/#{seed_name}.rb")
    eval(seed.read)
  end

  # Builds the url to visit for end-to-end tests referring to deploy settings "test" setting
  #
  # route - Rails route to append
  def build_url_for_capybara(route)
    host = get_deploy_setting("test", {})
    if host["port"]
      "#{host["capybara_hostname"]}:#{host["port"]}#{route}"
    else
      "#{host["capybara_hostname"]}#{route}"
    end
  end

  # Performs a login with the given parameters
  def login_with_data(user_email, user_password)
    perform_logout
    visit(build_url_for_capybara("/users/sign_in"))
    within("form#new_user") do
      fill_in "user_email", :with => user_email
      fill_in "user_password", :with => user_password
      click_button("")
    end
  end

  def admin_login
    login_with_data("fragazzo@shado.tv", "shado00")
  end

  def perform_logout
    visit(build_url_for_capybara("/users/sign_out"))
  end

  def visit_home
    visit(build_url_for_capybara(""))
  end

  def reload_page
    visit(build_url_for_capybara(current_path))
  end

  def delete_user_interactions
    visit(build_url_for_capybara("/delete_current_user_interactions"))
  end

  # Loops until all ajax requests have finished
  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end

  # Loops until all AngularJS requests have finished
  def wait_for_angular
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_angular_requests?
    end
  end

  def finished_all_angular_requests?
    page.evaluate_script '(typeof angular === "undefined") || (angular.element(".ng-scope").injector().get("$http").pendingRequests.length == 0)'
  end

  # Finds the call to action with a specific title
  #
  # title - Cta title
  # visit - Boolean value; if true, capybara visits the call to action page
  #
  # Returns call to action complete url if visit is not true
  def login_and_find_call_to_action_with_title(title, visit = false)
    admin_login
    visit(build_url_for_capybara("/easyadmin/cta"))
    fill_in "title_filter", :with => title
    page.find("input[value='APPLICA FILTRO']").click

    cta_link = first("a[href^='/call_to_action/']")[:href]

    if visit
      visit(cta_link)
    else
      cta_link
    end
  end

  # Gives an answer and returns current user points after this action
  #
  # points - User points before performing answer, useful to check points adding; can be nil
  # button_type - String containing HTML button tag (usually, "button" or "a")
  # text - Exact text inside button, in order to recognize the answer
  #
  # Returns total points after action
  def get_points_after_answer(points, button_type, text)
    page.find(button_type, :text => text).click

    wait_for_angular

    new_points = get_user_points_from_single_call_to_action_page()
    assert new_points > points, "No point given for answer \"#{text}\"" if points
    new_points
  end

  # Finds and returns current user main reward points when in single call to action page
  def get_user_points_from_single_call_to_action_page
    points = nil
    within("div[ng-if='!isAnonymousUser()']") do
      points = find("span.cta-cover__winnable-reward__label").text
    end
    points.gsub("+", "").to_i
  end

  # Tests if green "Done" label is present or not
  #
  # Examples
  #
  #   verify_done_label_presence("check-undervideo-interaction__row", false)
  #   ...
  #   verify_done_label_presence("check-undervideo-interaction__row", true)
  #
  # div_last_class - Last identifying class for div that should contain "Done" label
  # should_be_present - Boolean value to perform presence or absence assertion
  def verify_done_label_presence(div_last_class, should_be_present)
    within("div[class$='#{div_last_class}']") do 
      if should_be_present
        assert assert_selector("span[class^='label label-success']"), "Success label is not present"
      else
        assert assert_no_selector("span[class^='label label-success']"), "Success label is present even if it shouldn't be"
      end
    end    
  end

  def quiz?(resource_type)
    resource_type == "Quiz"
  end

  def get_random_property
    random_property_name = $site.allowed_context_roots.sample
    Tag.find(random_property_name)
  end

  def get_default_property
    Tag.find($site.default_property)
  end

  def current_user
    @current_user.nil? ? User.find_by_email("atolomio@shado.tv") : @current_user
  end

  def initialize_tenant
    switch_tenant("fandom")
  end

  def get_counter(ref_type, ref_id)
    ViewCounter.where(ref_type: ref_type, ref_id: ref_id).first
  end

  def lorem_ipsum()
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  end

  def destroy_user_interactions()
    UserInteraction.where(user_id: current_user.id).destroy_all if current_user.present?
  end

  # SEEDS HELPER

  def build_quiz_interaction(cta, quiz_type, one_shot = true)
    resource = Quiz.new(question: lorem_ipsum, quiz_type: quiz_type, one_shot: one_shot)

    answers_correctly = quiz_type == "TRIVIA" ? [CORRECT_ANSWER, INCORRECT_ANSWER] : [INCORRECT_ANSWER, INCORRECT_ANSWER]

    answers_correctly.each do |correct|
      resource.answers.build(text: lorem_ipsum, correct: correct)
    end

    resource.save

    build_interaction(cta, resource)
  end

  def build_base_interaction(cta, resource_type, params = {})
    resource = Object.const_get(resource_type).create(params)
    build_interaction(cta, resource)  
  end

  def build_interaction(cta, resource)
    Interaction.create(
      resource: resource, 
      when_show_interaction: "SEMPRE_VISIBILE",
      call_to_action_id: cta.id,
      registration_needed: false
    )
  end

end