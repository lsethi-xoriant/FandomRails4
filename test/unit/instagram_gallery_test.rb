require "test_helper"

class InstagramGalleryTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    switch_tenant("fandom")
    load_seed("default_seed")
    @upload_interaction = load_seed("instagram_gallery")
    @controller = CallbackController.new
  end

  test "instagram new tagged media callback" do

    user_cta_count = user_call_to_actions_containing("#fandom_shado").count

    params = {"_json"=>[{"changed_aspect"=>"media", "object"=>"tag", "object_id"=>"fandom_shado", "time"=>1432222842, "subscription_id"=>18261539, "data"=>{}}], "controller"=>"callback", "action"=>"instagram_new_tagged_media_callback", "tag_name"=>"fandom_shado", "callback"=>{"_json"=>[{"changed_aspect"=>"media", "object"=>"tag", "object_id"=>"fandom_shado", "time"=>1432222842, "subscription_id"=>18261539, "data"=>{}}]}}

    post(:instagram_new_tagged_media_callback, params)

    assert_response :success, "Response was not successful"
    assert @response.body == "OK", "Response was \"#{@response.body}\" instead of \"OK\""

    user_call_to_actions_created = user_call_to_actions_containing("#fandom_shado")
    user_call_to_actions_created_count = user_call_to_actions_created.count - user_cta_count
    assert user_call_to_actions_created_count > 0, "No user call to action created"
    puts "\n#{user_call_to_actions_created_count} user call to actions successfully created"

    user_call_to_actions_created.each do |cta|
      assert cta.extra_fields["layout"] == "instagram", "extra_field \"layout\" is not \"instagram\" for call to action '#{cta.name}'"
    end

  end

  def user_call_to_actions_containing(hashtag)
    CallToAction.where("created_at > '#{DateTime.now.beginning_of_day}' AND user_id IS NOT NULL AND title ILIKE '#{hashtag}'")
  end

end