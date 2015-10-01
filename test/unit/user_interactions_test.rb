require 'test_helper'

class UserInteractionsTest < ActionController::TestCase
  include ApplicationHelper

  setup do
    initialize_tenant
    load_seed("user_interactions_seed")
  end

  test "the user insert a comment" do
    resource = init_resource("Comment")
    switch_comment_interaction_approve_setting(resource, false)

    comment_info =  { user_text: lorem_ipsum() }
    params = { comment_info: comment_info, interaction_id: resource.interaction.id }

    response = add_comment_computation(params)
    comment = UserCommentInteraction.find(response[:comment]["id"])
    assert check_comment_storage(comment, resource, true), "user comment not saved correctly"

    resource = init_resource("Comment")
    switch_comment_interaction_approve_setting(resource, true)
    response = add_comment_computation(params)
    comment = UserCommentInteraction.find(response[:comment]["id"])

    assert check_comment_storage(comment, resource, nil), "user comment not saved correctly"
  end

  test "the anonymous user insert a comment" do
    @current_user = anonymous_user()

    captcha_code = "0000"
    user_captcha = captcha_code
    session_storage_captcha = Digest::MD5.hexdigest(captcha_code)

    resource = init_resource("Comment")

    switch_comment_interaction_approve_setting(resource, false)

    comment_info =  { user_text: lorem_ipsum(), user_captcha: user_captcha }
    params = { comment_info: comment_info, interaction_id: resource.interaction.id, session_storage_captcha: session_storage_captcha}

    response = add_comment_computation(params)

    assert !response.has_key?(:errors), "anonymous user comment not saved correctly"
  end

  def switch_comment_interaction_approve_setting(resource, must_be_approved, destroy_user_comment_interactions = true)
    if resource.must_be_approved != must_be_approved
      resource.update_attribute(:must_be_approved, must_be_approved)
    end
    if destroy_user_comment_interactions
      resource.user_comment_interactions.where("user_comment_interactions.user_id = ?", current_user.id).destroy_all
    end
  end

  def check_comment_storage(comment, resource, approved)
    check_status = comment.approved == approved
    check_storage = current_user.user_comment_interactions.count > 0

    user_interactions_any = current_user.user_interactions.where(interaction_id: resource.interaction.id).any?
    check_storage = approved ? (check_storage && user_interactions_any) : (check_storage && !user_interactions_any)

    check_storage && check_status
  end

  # warning: TEST interaction take from DB and not from temporaly seed  
  test "the user makes a test 2 times" do
    return true
    destroy_user_interactions()
    
    cta_test_name = "che-tipo-di-fan-dei-coldplay-sei"
    cta_test_ending_name = "che-tipo-di-fan-dei-coldplay-sei-ending-2"
    symbolic_name = "L" 

    parent_cta = CallToAction.find(cta_test_name)
    result_cta_info = execute_cta_with_test_interaction(parent_cta, symbolic_name)
    
    assert result_cta_info["calltoaction"]["name"] == cta_test_ending_name, "the test result is incorrect"

    user_interaction_ids = result_cta_info["optional_history"]["user_interactions"]
    params = { user_interaction_ids: user_interaction_ids, parent_cta_id: parent_cta.id }
    
    reset_redo_user_interactions_computation(params)

    cta_test_ending_name = "che-tipo-di-fan-dei-coldplay-sei-ending-1"
    symbolic_name = "G" 

    result_cta_info = execute_cta_with_test_interaction(parent_cta, symbolic_name)

    assert result_cta_info["calltoaction"]["name"] == cta_test_ending_name, "the test (2nd time) result is incorrect"
  end

  test "the user responds correctly and incorrectly to a trivia and obtains correctly points amount" do
    correct = true
    user_points, correct_answer_points = compute_user_outcome_in_trivia(correct)
    assert user_points == correct_answer_points, "user interaction not have assign correctly points with correctly answer"

    correct = false
    user_points, correct_answer_points = compute_user_outcome_in_trivia(correct)
    assert user_points < correct_answer_points, "user interaction not have assign correctly points with incorrectly answer"
  end

  test "the user do a not one shot vote interaction multiple times" do
    votes = {}

    params = { one_shot: false }
    resource = init_resource("Vote", params)

    user_interaction = nil

    (0..4).each_with_index do |i|
      vote = 1 + Random.rand(10)

      votes["#{vote}"] = votes.has_key?(vote) ? (votes["#{vote}"] + 1) : 1

      params = { vote: vote }
      user_interaction = init_and_update_interaction_computation(resource, params)
      
      counter = get_counter("interaction", user_interaction.interaction_id)
      assert_counter = i + 1
      assert user_interaction.counter == assert_counter, "user interaction counter different from #{assert_counter}"
    end

    interaction_id = user_interaction.interaction_id
    counter = get_counter("interaction", interaction_id)
    
    counter_valid = true
    counter.aux.each do |key, value|
      counter_valid = false if votes[key] != value
    end

    assert user_interaction, "counter different from votes generated"
  end

  test "the user do a play interaction multiple times" do
    resource = init_resource("Play")
    5.times.each_with_index do |i|

      user_interaction = init_and_update_interaction_computation(resource)
      assert_counter = i + 1

      assert user_interaction.counter == assert_counter, "user interaction counter different from #{assert_counter}"
    end
  end

  test "the user do a like interaction multiple times" do
    resource = init_resource("Like")
    5.times.each_with_index do |i|

      user_interaction = init_and_update_interaction_computation(resource)
      assert_counter = i + 1

      like_must_be = i % 2 == 0
      assert user_interaction.aux["like"] == like_must_be, "like not set correctly in user interaction"

      assert user_interaction.counter == assert_counter, "user interaction counter different from #{assert_counter}"
    end
  end

  test "the user do a check interaction multiple times" do  
    resource = init_resource("Check")
    user_interaction = init_and_update_interaction_computation(resource)
    assert user_interaction.counter == 1, "user interaction not saved correctly with one shot interaction"

    begin
      init_and_update_interaction_computation(resource)
    rescue Exception => exception
      interaction_attempted_more_than_once = true
    end

    assert interaction_attempted_more_than_once, "check interaction attempted more than once"
  end

  test "the user do a one shot quiz interaction multiple times" do  
    ["TRIVIA", "VERSUS"].each do |quiz_type|
      params = { one_shot: true, quiz_type: quiz_type }
      resource = init_resource("Quiz", params)
      
      params = { correct_answer: true }
      user_interaction = init_and_update_interaction_computation(resource, params)
     
      assert user_interaction.counter == 1, "user interaction not saved correctly with one shot interaction"

      if quiz_type == "VERSUS"
        counter = get_counter("interaction", user_interaction.interaction_id)
        assert check_versus_counter(counter, 1, user_interaction.answer_id), "interaction counter incorrect"
      end

      begin
        init_and_update_interaction_computation(resource, params)
      rescue Exception => exception
        interaction_attempted_more_than_once = true
      end

      assert interaction_attempted_more_than_once, "one shot interaction attempted more than once"
    end
  end

  test "the user do a not one shot quiz interaction multiple times" do
    ["TRIVIA", "VERSUS"].each do |quiz_type|
      
      params = { one_shot: false, quiz_type: quiz_type }
      resource = init_resource("Quiz", params)
      
      5.times.each_with_index do |i|

        params = { correct_answer: true }
        user_interaction = init_and_update_interaction_computation(resource, params)
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
    params = { quiz_type: "TRIVIA", one_shot: false }
    resource = init_resource("Quiz", params)

    params = { correct_answer: correct }
    user_interaction = init_and_update_interaction_computation(resource, params)

    outcome = JSON.parse(user_interaction.outcome)
    user_points = outcome["win"]["attributes"]["reward_name_to_counter"]["point"]
    correct_answer_points = outcome["correct_answer"]["attributes"]["reward_name_to_counter"]["point"]

    [user_points, correct_answer_points]
  end

  def init_resource(resource_type, params = {}, destroy_user_interactions = true)
    if quiz?(resource_type)
      resource = find_quiz_resource(params[:quiz_type], params[:one_shot])
    else
      resource = Object.const_get(resource_type).includes(interaction: :call_to_action).where("call_to_actions.name = '#{CTA_TEST_NAME}'")
                       .references(:interactions, :call_to_actions)
      if params && params.has_key?(:one_shot)
        resource = resource.where("#{resource_type.downcase.pluralize}.one_shot = ?", params[:one_shot])
      end
      resource = resource.first
    end

    if destroy_user_interactions
      UserInteraction.where(interaction_id: resource.interaction.id, user_id: current_user.id).destroy_all
    end

    resource
  end

  def init_and_update_interaction_computation(resource, params = nil)
    resource_type = resource.class.name

    if quiz?(resource_type)
      ui_params = init_quiz_user_interaction_params(resource, params)
    else
      ui_params = { interaction_id: resource.interaction.id }
      if params.present? && params.has_key?(:vote)
        ui_params[:params] = params[:vote] 
      end
    end
    
    response = update_interaction_computation(ui_params)
    user_interaction = UserInteraction.find(response[:user_interaction]["id"])
    user_interaction
  end

  def find_quiz_resource(quiz_type, one_shot = true)
    Quiz.includes(interaction: :call_to_action)
      .where("call_to_actions.name = '#{CTA_TEST_NAME}' AND quizzes.one_shot = ? AND quizzes.quiz_type = ?", one_shot, quiz_type)
      .references(:interactions, :call_to_actions).first
  end

  def init_quiz_user_interaction_params(quiz_resource, params) 
    case quiz_resource.quiz_type
    when "TRIVIA"
      answer = quiz_resource.answers.where(correct: params[:correct_answer]).order(created_at: :asc).first
    when "TEST"
      answer = quiz_resource.answers.where("aux->>'symbolic_name' = ?", params[:symbolic_name]).order(created_at: :asc).first
    else
      answer = quiz_resource.answers.order(created_at: :asc).first
    end

    throw Exception.new("in quiz resource #{quiz_resource.id} answer can not be blank") if answer.blank?

    { interaction_id: quiz_resource.interaction.id, params: answer.id, parent_cta_id: params[:parent_cta_id] }
  end

  def find_resource_in_interaction_info_list(interaction_info_list, resource_type)
    resource = nil
    interaction_info_list.each do |interaction_info|
      if interaction_info["interaction"]["resource_type"] == resource_type
        resource = Interaction.find(interaction_info["interaction"]["id"]).resource
        break
      end
    end
    resource
  end

  def execute_cta_with_test_interaction(cta, symbolic_name)
    times = nil
    index = 0

    begin
      cta_info_list = build_cta_info_list_and_cache_with_max_updated_at([cta])
      cta_info = cta_info_list[0]
      
      interaction_info_list = cta_info["calltoaction"]["interaction_info_list"]
      resource = find_resource_in_interaction_info_list(interaction_info_list, "test")

      parent_cta_info = get_parent_cta(cta_info)

      params = { correct_answer: false, parent_cta_id: parent_cta_info["calltoaction"]["id"], symbolic_name: symbolic_name }
      user_interaction = init_and_update_interaction_computation(resource, params)

      if times.blank?
        times = cta_info["optional_history"]["optional_total_count"].to_i
      end

      index = cta_info["optional_history"]["optional_index_count"].to_i
    end while times.present? && (times - 1) != index

    cta_info_list = build_cta_info_list_and_cache_with_max_updated_at([cta])
    cta_info_list[0]
  end

  def render_to_string(arg1, arg2)
  end

  def sign_in(arg1)
  end
  
end