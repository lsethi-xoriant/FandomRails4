require "test_helper"
require "byebug"
class VersusInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "versus interaction" do

    cta_link = call_to_action_with_title("Cta with versus interaction")

    delete_user_interactions

    answers_points = {}

    ["One", "Two", "Three", "Four"].each do |answer|
      answers_points[answer] = get_versus_answer_points(cta_link, answer)
    end

    answers_points.each do |answer, points|
      assert_not points.zero?, "Answer \"#{answer}\" gave 0 points"
    end

    assert answers_points.values.uniq.count == 1, "Different points amount given for two versus answer"

    admin_logout

  end

  def get_versus_answer_points(cta_link, answer)
    visit(cta_link)
    verify_done_label_presence("interaction__winnable-reward--undervideo", false)
    starting_points = get_user_points_from_single_call_to_action_page
    points_after_versus_answer = get_points_after_answer(starting_points, "a", answer)
    versus_answer_points = points_after_versus_answer - starting_points
    verify_done_label_presence("interaction__winnable-reward--undervideo", true)
    delete_user_interactions
    versus_answer_points
  end

end