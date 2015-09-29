require "test_helper"

class LinkedCallToActionHelperTest < ActiveSupport::TestCase

  setup do
    switch_tenant("fandom")
    @starting_cta, @cta_1, @cta_2 = load_seed("linked_call_to_actions")
  end

  test "node creation" do
    build_node("Childfree node", [])
    build_node("Banana", ["Apple", "Pear"])
  end

  test "seeds linked call to actions structure" do
    Rails.cache.clear
    trees, cycles = CtaForest.build_trees(@starting_cta.id)

    assert cycles.empty?, "There shouldn't be any cycle"
    assert trees.size == 1, "There should be only one tree, but #{ trees.size } trees have been created."
    assert trees.first.value == @starting_cta.id, "Root value should be #{ @starting_cta.id }, but is #{ trees.first.value }"

    children_values = trees.first.children.map{|c| c.value}
    assert children_values.include?(@cta_1.id), "Cta #{ @cta_1.id } should be #{ trees.first.value } child"
    assert children_values.include?(@cta_2.id), "Cta #{ @cta_2.id } should be #{ trees.first.value } child"

    assert is_linking?(@starting_cta.id) == true, "Cta #{ @starting_cta.id } is linking"
    assert is_linking?(@cta_1.id) == false, "Cta #{ @cta_1.id } is not linking"
    assert is_linking?(@cta_2.id) == false, "Cta #{ @cta_2.id } is not linking"

    assert is_linked?(@starting_cta.id) == false, "Cta #{ @starting_cta.id } is not linked by other ctas"
    assert is_linked?(@cta_1.id) == true, "Cta #{ @cta_1.id } is linked by another cta"
    assert is_linked?(@cta_2.id) == true, "Cta #{ @cta_2.id } is linked by another cta"
  end

  test "cycles detection" do
    Rails.cache.clear
    cta_3 = CallToAction.create(:title => "3", :name => "three")
    cta_3_interaction = Interaction.create(:call_to_action_id => cta_3.id)
    add_link(@cta_2, cta_3)
    add_link(cta_3, @starting_cta)

    trees, cycles = CtaForest.build_trees(@starting_cta.id)

    assert cycles.any?, "There should be a cycle"
    assert trees.size == 1, "There should be only one tree, but #{ trees.size } trees have been created."
  end

  def build_node(root_value, children_values)
    n = Node.new(root_value)
    assert n.value == root_value, "Node value should be \"#{ root_value }\" but it is \"#{ n.value }\""

    children_values.each do |child_value|
      n.children.push(Node.new(child_value))
    end
  end

  # Public: Just links first cta_1 interaction to cta_2 creating related interaction_call_to_actions_entry.
  # It is useful to build cta links for test only.
  def add_link(cta_1, cta_2)
    interaction_id = cta_1.interactions.all.first.id
    InteractionCallToAction.create(:interaction_id => interaction_id, :call_to_action_id => cta_2.id)
  end

end