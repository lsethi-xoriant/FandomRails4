require "test_helper"

class TriviaInteraction < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "trivia interaction" do

    cta_link = call_to_action_with_title("Cta with trivia interaction")

    delete_user_interactions

    visit(cta_link)
    starting_points = get_user_points_from_single_call_to_action_page
    points_after_correct_answer = get_answer_points(starting_points, "button", "Right")
    correct_answer_points = points_after_correct_answer - starting_points

    delete_user_interactions

    visit(cta_link)
    starting_points = get_user_points_from_single_call_to_action_page
    points_after_wrong_answer = get_answer_points(starting_points, "button", "Wrong 1")
    wrong_answer_points = points_after_wrong_answer - starting_points

    assert correct_answer_points > wrong_answer_points, "#{correct_answer_points} points given to right answer, #{wrong_answer_points} points given to wrong answer"

    delete_user_interactions

    visit(cta_link)
    starting_points = get_user_points_from_single_call_to_action_page
    points_after_wrong_answer = get_answer_points(starting_points, "button", "Wrong 2")
    wrong_answer_2_points = points_after_wrong_answer - starting_points

    assert wrong_answer_points == wrong_answer_2_points, "Different amount of points given to two wrong answers (#{wrong_answer_points} and #{wrong_answer_2_points})"

    delete_user_interactions

    admin_logout

  end

end