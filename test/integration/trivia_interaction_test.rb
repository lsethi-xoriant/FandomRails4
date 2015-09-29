require "test_helper"

class TriviaInteractionTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
  end

  test "trivia interaction" do

    cta_link = login_and_find_call_to_action_with_title("Cta with trivia interaction")

    correct_answer_points = trivia_answer_test(cta_link, "Right")
    wrong_answer_points = trivia_answer_test(cta_link, "Wrong 1")

    assert correct_answer_points >= wrong_answer_points, "#{correct_answer_points} points given to right answer, #{wrong_answer_points} points given to wrong answer"

    wrong_answer_2_points = trivia_answer_test(cta_link, "Wrong 2")

    assert wrong_answer_points == wrong_answer_2_points, "Different amount of points given to two wrong answers (#{wrong_answer_points} and #{wrong_answer_2_points})"

    delete_user_interactions

    perform_logout

  end

  def trivia_answer_test(cta_link, answer)
    delete_user_interactions

    visit(cta_link)
    verify_done_label_presence("interaction__winnable-reward--undervideo", false)
    starting_points = get_user_points_from_single_call_to_action_page
    points_after_answer = get_points_after_answer(starting_points, "a", answer)
    verify_done_label_presence("interaction__winnable-reward--undervideo", true)
    points_after_answer - starting_points
  end

end