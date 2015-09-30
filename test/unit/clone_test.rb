require "test_helper"
require "byebug"

class CloneTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    switch_tenant("fandom")
    @controller = Easyadmin::CallToActionController.new
    @cta, @resources, @reward = load_seed("instances_to_be_cloned")
    @root_cta, @child_cta_1, @child_cta_2 = load_seed("linked_call_to_actions")
    @users = load_seed("default_seed")
    @cloned_cta = duplicate_cta(@cta.id)
  end

  test "duplicate cta method" do

    check_attributes_equality(@cta, @cloned_cta, ["id", "title", "name", "slug", "activated_at"])
    assert @cloned_cta.title == "Copy of " + @cta.title, "Cloned_cta title should be '#{"Copy of " + @cta.name}', but it is '#{@cloned_cta.title}'"
    assert @cloned_cta.name == "copy-of-" + @cta.name, "Cloned_cta name should be '#{"copy-of-" + @cta.name}', but it is '#{@cloned_cta.name}'"
    assert @cloned_cta.slug == "copy-of-" + @cta.slug, "Cloned_cta slug should be '#{"copy-of-" + @cta.slug}', but it is '#{@cloned_cta.slug}'"
    assert @cloned_cta.activated_at.present?, "Cloned_cta activated_at is nil"
    assert @cloned_cta.valid?, "Cloned_cta is not valid -> #{@cloned_cta.errors.messages}"

  end

  test "duplicate interaction method" do

    interactions = Interaction.where(:call_to_action_id => @cta.id)
    assert interactions.count > 0, "Call to action to be cloned has no interactions"

    interactions.each do |interaction|
      cloned_interaction = duplicate_interaction(@cloned_cta, interaction)
      check_attributes_equality(interaction, cloned_interaction, ["id", "name", "resource_id", "call_to_action_id"])
      check_attributes_equality(interaction.resource, cloned_interaction.resource, ["id", "title"])
    end

  end

  test "clone linking cta method" do
    
    admin_login

    cta_id = CallToAction.where(:slug => "che-tipo-di-fan-dei-coldplay-sei").first.id
    assert is_linking?(cta_id), "is_linking method called on linked call to action returned false"

    visit(build_url_for_capybara("/easyadmin/cta/clone/#{cta_id}"))

    assert page.find("form")[:action].include?("post"), "Form for linking cta does not have action = post"

    within("form") do
      fill_in "cloned_cta_title", :with => "Cloned cta title for testing"
      assert page.find("input#cloned_cta_name").value == "cloned-cta-title-for-testing", 
        "Cloned cta name is \"#{page.find("input#cloned_cta_name").text}\" instead of \"cloned-cta-title-for-testing\""
      assert page.find("input#cloned_cta_che-tipo-di-fan-dei-coldplay-sei-step-1_name").value == "cloned-cta-title-for-testing-step-1", 
        "Cloned linked cta name is \"#{page.find("input#cloned_cta_che-tipo-di-fan-dei-coldplay-sei-step-1_name").text}\" instead of \"cloned-cta-title-for-testing-1\""
    end

  end

  test "duplicate reward method" do

    cloned_reward = duplicate_reward(@reward.id)
    check_attributes_equality(@reward, cloned_reward, ["id", "name", "title", "created_at"])
    assert cloned_reward.title == "Copy of " + @reward.title, "Cloned_reward title should be '#{"Copy of " + @reward.title}', but it is '#{cloned_reward.title}'"
    assert cloned_reward.valid?, "Cloned_reward is not valid -> #{cloned_reward.errors.messages}"

  end

  def check_attributes_equality(original, cloned, except_values)
    cloned.attributes.except(*except_values).each do |attribute_name, value|
      assert value == original.attributes[attribute_name], "#{attribute_name} attribute has value \"#{original.attributes[attribute_name]}\" on original #{original.class}, but \"#{value}\" on cloned"
    end
  end

end