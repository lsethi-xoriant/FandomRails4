require 'test_helper'

class UserInteractionsTest < ActionController::TestCase
  include ApplicationHelper

  DESTROY_USER_INTERACTIONS = true

  setup do
    initialize_tenant
    load_seed("user_interactions_seed")
  end

  test "user do a one shot quiz interaction" do    
    one_shot = true
    quiz_resource = nil
    user_interaction, quiz_resource = update_interaction_computation_with_quiz_interaction(quiz_resource, one_shot, DESTROY_USER_INTERACTIONS)
    assert user_interaction.counter == 1, "user interaction not saved correctly with one shot interaction"

    begin
      update_interaction_computation_with_quiz_interaction(quiz_resource, one_shot)
    rescue Exception => exception
      interaction_attempted_more_than_once = true
    end

    assert interaction_attempted_more_than_once, "one shot interaction attempted more than once"
  end

  test "user do a not one shot quiz interaction" do
    one_shot = false
    quiz_resource = nil

    5.times.each_with_index do |i|
      destroy_user_interactions = (i == 0)
      user_interaction, quiz_resource = update_interaction_computation_with_quiz_interaction(quiz_resource, one_shot, destroy_user_interactions)
      counter = i + 1
      assert user_interaction.counter == counter, "user interaction counter different from #{counter}"
    end
  end

  def update_interaction_computation_with_quiz_interaction(quiz_resource, one_shot, destroy_user_interactions = false)
    if quiz_resource.nil?
      quiz_resource = Quiz.includes(interaction: :call_to_action)
              .where("call_to_actions.name = 'cta-for-user-interactions-testing' AND quizzes.one_shot = ?", one_shot)
              .references(:interactions, :call_to_actions).first
    end

    if destroy_user_interactions
      UserInteraction.where(interaction_id: quiz_resource.interaction.id, user_id: current_user.id).destroy_all
    end
    
    params = init_quiz_interaction_params(quiz_resource)
    response = update_interaction_computation(params)
    user_interaction = UserInteraction.find(response[:user_interaction]["id"])
    [user_interaction, quiz_resource]
  end

  def init_quiz_interaction_params(quiz_resource) 
    { interaction_id: quiz_resource.interaction.id, params: quiz_resource.answers.where(correct: true).first.id }
  end

  def render_to_string(arg1, arg2)
  end
  
end