require "test_helper"

class RandomInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "random interaction" do

    counters = {}
    for i in 1..5
      counters[i] = 0
    end

    login_and_find_call_to_action_with_title("Cta with random interaction 1", true)
    counters[cta_number] += 1

    for i in 1..9
      within("div.randomresource-undervideo-interaction__row") do
        page.find("a[ng-click^='updateAnswer']").click
      end
      counters[cta_number] += 1
      wait_for_angular
    end

    counters.each do |value, count|
      assert count < 10, "Random interaction always gave call to action number #{value}"
    end

    delete_user_interactions
    perform_logout

  end

  def cta_number
    find("h1[class^='cta__title']").text[-1].to_i
  end

end