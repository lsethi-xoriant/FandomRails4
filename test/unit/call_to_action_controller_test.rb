require "test_helper"

class CallToActionControllerTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    switch_tenant("fandom")
    load_seed("profanity_settings")
    @users = load_seed("default_seed")
    @interaction = load_seed("call_to_action_controller")
  end

  test "200 code for active call to action" do

    visit(build_url_for_capybara("/call_to_action/312")) # Qual è la canzone più romantica della discografia dei Coldplay?
    assert first("div[class='container main-container']"), "Call to action visualization problems"

  end

  test "add comment for current user" do

    assert current_user, "Didn't find current_user"
    assert current_user.anonymous_id.nil?, "current_user.anonymous_id is not nil"

    post_comment_response_test("Comment with no curse", @interaction, true)
    post_comment_response_test("Comment with profanity", @interaction, false)

  end

  def post_comment_response_test(comment_text, interaction, it_should_pass)
    params = { :interaction_id => interaction.id, :comment_info => { :user_text => comment_text }, :format => :json }
    post(:add_comment, params)

    assert_response :success, "Response was not successful"

    response_hash = JSON.parse(@response.body)
    assert response_hash["errors"].nil?, "Errors on response: #{ response_hash["errors"] }"

    assert response_hash["approved"] == it_should_pass, "Comment approvation should have status #{it_should_pass}, but it has status \"#{ response_hash["approved"] }\""
  end

  def current_user
    @users.sample
  end

end