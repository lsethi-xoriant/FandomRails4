require 'test_helper'

class UserInteractionsTest < ActionController::TestCase
  include ApplicationHelper

  DESTROY_USER_INTERACTIONS = true
  ONE_SHOT = true
  CORRECT = true

  setup do
    initialize_tenant
    load_seed("user_interactions_seed")
  end

  test "the user responds correctly and incorrectly to a trivia and obtains correctly points amount" do
    user_points, correct_answer_points = compute_user_outcome_in_trivia(CORRECT)
    assert user_points == correct_answer_points, "user interaction not have assign correctly points with correctly answer"

    user_points, correct_answer_points = compute_user_outcome_in_trivia(!CORRECT)
    assert user_points < correct_answer_points, "user interaction not have assign correctly points with incorrectly answer"
  end

  test "the user do a not one shot vote interaction multiple times" do
    votes = []
    resource = user_interaction = nil
    5.times.each_with_index do |i|
      destroy_user_interactions = (i == 0)
      vote = 1 + Random.rand(10)
      votes << vote
      params = { vote: vote, one_shot: !ONE_SHOT }
      puts "-----------"
      user_interaction, resource = update_interaction_computation_with_interaction(resource, "Vote", params, destroy_user_interactions)
      assert_counter = i + 1

      assert user_interaction.counter == assert_counter, "user interaction counter different from #{assert_counter}"
    end
    puts votes.to_json
    puts user_interaction
  end

  test "the user do a play interaction multiple times" do
    resource = nil
    5.times.each_with_index do |i|
      destroy_user_interactions = (i == 0)
      params = nil
      user_interaction, resource = update_interaction_computation_with_interaction(resource, "Play", params, destroy_user_interactions)
      assert_counter = i + 1

      assert user_interaction.counter == assert_counter, "user interaction counter different from #{assert_counter}"
    end
  end

  test "the user do a like interaction multiple times" do
    resource = nil
    5.times.each_with_index do |i|
      destroy_user_interactions = (i == 0)
      params = nil
      user_interaction, resource = update_interaction_computation_with_interaction(resource, "Like", params, destroy_user_interactions)
      assert_counter = i + 1

      like_must_be = i % 2 == 0
      assert user_interaction.aux["like"] == like_must_be, "like not set correctly in user interaction"

      assert user_interaction.counter == assert_counter, "user interaction counter different from #{assert_counter}"
    end
  end

  test "the user do a check interaction multiple times" do  
    resource = nil
    params = nil
    user_interaction, resource = update_interaction_computation_with_interaction(resource, "Check", params, DESTROY_USER_INTERACTIONS)
    assert user_interaction.counter == 1, "user interaction not saved correctly with one shot interaction"

    begin
      update_interaction_computation_with_interaction(resource, "Check", params)
    rescue Exception => exception
      interaction_attempted_more_than_once = true
    end

    assert interaction_attempted_more_than_once, "check interaction attempted more than once"
  end

  test "the user do a one shot quiz interaction multiple times" do  
    ["TRIVIA", "VERSUS"].each do |quiz_type|
      resource = nil
      
      params = init_quiz_params(quiz_type, ONE_SHOT)
      user_interaction, resource = update_interaction_computation_with_interaction(resource, "Quiz", params, DESTROY_USER_INTERACTIONS)
     
      assert user_interaction.counter == 1, "user interaction not saved correctly with one shot interaction"

      if quiz_type == "VERSUS"
        counter = get_counter("interaction", user_interaction.interaction_id)
        assert check_versus_counter(counter, 1, user_interaction.answer_id), "interaction counter incorrect"
      end

      begin
        update_interaction_computation_with_interaction(resource, "Quiz", params)
      rescue Exception => exception
        interaction_attempted_more_than_once = true
      end

      assert interaction_attempted_more_than_once, "one shot interaction attempted more than once"
    end
  end

  test "the user do a not one shot quiz interaction multiple times" do
    ["TRIVIA", "VERSUS"].each do |quiz_type|
      resource = nil
      5.times.each_with_index do |i|
        destroy_user_interactions = (i == 0)
        params = init_quiz_params(quiz_type, !ONE_SHOT)
        user_interaction, resource = update_interaction_computation_with_interaction(resource, "Quiz", params, destroy_user_interactions)
        assert_counter = i + 1

        if quiz_type == "VERSUS"
          counter = get_counter("interaction", user_interaction.interaction_id)
          assert check_versus_counter(counter, assert_counter, user_interaction.answer_id), "interaction counter incorrect"
        end

        assert user_interaction.counter == assert_counter, "user interaction counter different from #{assert_counter}"
      end
    end
  end

  def check_versus_counter(counter, assert_counter, answer_id)
    counter.counter == assert_counter && counter.aux["#{answer_id}"] == assert_counter
  end

  def compute_user_outcome_in_trivia(correct)
    resource = find_quiz_resource("TRIVIA")
    params = { one_shot: ONE_SHOT, correct_answer: correct, quiz_type: "TRIVIA" }
    user_interaction, resource = update_interaction_computation_with_interaction(resource, "Quiz", params, DESTROY_USER_INTERACTIONS)

    outcome = JSON.parse(user_interaction.outcome)
    user_points = outcome["win"]["attributes"]["reward_name_to_counter"]["point"]
    correct_answer_points = outcome["correct_answer"]["attributes"]["reward_name_to_counter"]["point"]

    [user_points, correct_answer_points]
  end

  def update_interaction_computation_with_interaction(resource, resource_type, params, destroy_user_interactions = false)
    if resource.nil?
      if quiz?(resource_type)
        resource = find_quiz_resource(params[:quiz_type], params[:one_shot])
      else
        if params && params.has_key?(:one_shot)
          resource = Object.const_get(resource_type).includes(interaction: :call_to_action)
                                                    .where("call_to_actions.name = '#{CTA_TEST_NAME}'")
                                                    .where("#{resource_type.downcase.pluralize}.one_shot = ?", params[:one_shot])
                                                    .references(:interactions, :call_to_actions).first
        else
          resource = Object.const_get(resource_type).includes(interaction: :call_to_action).where("call_to_actions.name = '#{CTA_TEST_NAME}'")
                         .references(:interactions, :call_to_actions).first
        end
      end
    end

    if quiz?(resource_type)
      ui_params = init_quiz_user_interaction_params(resource, params[:correct_answer])
    else
      ui_params = { interaction_id: resource.interaction.id }
      if params.present? && params.has_key?(:vote)
        ui_params[:vote] = params[:vote] 
      end
    end

    if destroy_user_interactions
      UserInteraction.where(interaction_id: resource.interaction.id, user_id: current_user.id).destroy_all
    end
    
    response = update_interaction_computation(ui_params)
    user_interaction = UserInteraction.find(response[:user_interaction]["id"])
    [user_interaction, resource]
  end

  def find_quiz_resource(quiz_type, one_shot = true)
    Quiz.includes(interaction: :call_to_action)
      .where("call_to_actions.name = '#{CTA_TEST_NAME}' AND quizzes.one_shot = ? AND quizzes.quiz_type = ?", one_shot, quiz_type)
      .references(:interactions, :call_to_actions).first
  end

  def init_quiz_params(quiz_type, one_shot)
    { one_shot: one_shot, correct_answer: CORRECT, quiz_type: quiz_type }
  end

  def init_quiz_user_interaction_params(quiz_resource, correct) 
    if quiz_resource.quiz_type == "TRIVIA"
      answer = quiz_resource.answers.where(correct: correct).order(created_at: :asc).first
    else
      answer = quiz_resource.answers.order(created_at: :asc).first
    end

    { interaction_id: quiz_resource.interaction.id, params: answer.id }
  end

  def render_to_string(arg1, arg2)
  end
  
end