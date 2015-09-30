require "test_helper"

class RandomInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "random interaction" do

    counters = {}

    login_and_find_call_to_action_with_title("Coin Gift Machine", true)
    counters[cta_title] = (counters[cta_title] || 0) + 1

    for i in 1..10
      within("div[ng-if^='interaction_info.interaction.resource_type ==']") do
        page.find("a[ng-click^='updateAnswer']").click
      end
      counters[cta_title] = (counters[cta_title] || 0) + 1
      wait_for_angular
    end

    counters.each do |title, count|
      assert count < 10, "Random interaction always gave call to action with title #{title}"
    end

    delete_user_interactions
    perform_logout

  end

  def cta_title
    find("h1[class^='cta__title']").text
  end

end