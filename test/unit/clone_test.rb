require "test_helper"

class CloneTest < ActionController::TestCase

  include Devise::TestHelpers

  setup do
    switch_tenant("fandom")
    @controller = Easyadmin::CallToActionController.new
    @cta, @resources = load_seed("instances_to_be_cloned")
    @cloned_cta = duplicate_cta(@cta.id)
    @root_cta, @child_cta_1, @child_cta_2 = load_seed("linked_call_to_actions")
  end

  test "duplicate cta method" do

    check_attributes_equality(@cta, @cloned_cta, ["id", "title", "name", "activated_at"])
    assert @cloned_cta.title == "Copy of " + @cta.title, "cloned_cta title should be '#{"Copy of " + @cta.name}', but it is '#{@cloned_cta.title}' instead"
    assert @cloned_cta.name == "copy-of-" + @cta.name, "cloned_cta name should be '#{"copy-of-" + @cta.name}', but it is '#{@cloned_cta.name}' instead"
    assert @cloned_cta.activated_at.present?, "cloned_cta activated_at is nil"
    assert @cloned_cta.valid?, "cloned_cta is not valid"

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

    params = { :id => @root_cta.id, :commit => "SALVA" }
    assert is_linking?(params[:id]), "is_linking method called on linked call to action returned false"
    post(:clone, params)
    puts flash[:error]
    puts flash[:notice]
    puts flash.keys

  end

  def check_attributes_equality(original, cloned, except_values)
    cloned.attributes.except(*except_values).each do |attribute_name, value|
      assert value == original.attributes[attribute_name], "#{attribute_name} attribute has value '#{original.attributes[attribute_name]}'' on original #{original.class}, but '#{value}' on cloned"
    end
  end

end