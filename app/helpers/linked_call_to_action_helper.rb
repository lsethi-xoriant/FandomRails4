module LinkedCallToActionHelper

  # Internal: Custom class and methods useful to represent the set of trees containing a call 
  # to action following linking paths defined in interaction_call_to_actions table and cta answer call_to_action_id.
  # Based on Node class, every single tree is identified by its root Node.
  class CtaForest

    # Internal: Builds the graph of all the reachable call to actions from a given cta.
    # reachable_cta_id_set is the all reachable call to actions ids from starting call to action set.
    #
    # starting_cta_id - Call to action id to reach.
    # return_tree - Boolean value for structure to return.
    #
    # Returns the graph starting from starting_cta_id and the cycles boolean value.
    def self.build_linked_cta_graph(starting_cta_id)
      cache_key = starting_cta_id
      cta_ids = CtaForest.get_neighbourhood_map().keys
      cache_timestamp = get_cta_max_updated_at(cta_ids)

      seen_nodes, cycles = cache_forever(get_linked_cta_graph_cache_key(cache_key, cache_timestamp)) do
        reachable_cta_id_set = build_reachable_cta_set(starting_cta_id, Set.new([starting_cta_id]), [])
        seen_nodes = {}
        cycles = []
        reachable_cta_id_set.each do |cta_id|
          if seen_nodes[cta_id].nil? and !in_cycles(cta_id, cycles)
            tree = Node.new(cta_id)
            tree, cycles = add_next_cta(seen_nodes, tree, cycles, [cta_id])
          end
        end
        [seen_nodes, cycles]
      end
      [seen_nodes, cycles]
    end

    def self.build_trees(starting_cta_id)
      seen_nodes, cycles = build_linked_cta_graph(starting_cta_id)
      reachable_cta_id_set = build_reachable_cta_set(starting_cta_id, Set.new([starting_cta_id]), [])
      trees = []
      reachable_cta_id_set.each do |cta_id|
        if (InteractionCallToAction.find_by_call_to_action_id(cta_id).nil? && Answer.where(:call_to_action_id => cta_id).count == 0) or (cycles.any? and cta_id == starting_cta_id) # add roots
          trees << seen_nodes[cta_id]
        end
      end
      return trees, cycles
    end

    # Internal: Builds the undirected graph of all linked call to actions
    #
    # Returns a hash of (cta_id => Set of reachable cta ids) couples
    def self.get_neighbourhood_map()
      cache_timestamp = get_cta_max_updated_at()

      neighbourhood_map = cache_forever(get_linked_ctas_cache_key(cache_timestamp)) do
        neighbourhood_map = {}
        InteractionCallToAction.all.each do |interaction_call_to_action|
          if interaction_call_to_action.interaction_id.present?
            cta_linking_id = Interaction.find(interaction_call_to_action.interaction_id).call_to_action_id
            cta_linked_id = interaction_call_to_action.call_to_action_id
            add_neighbour(neighbourhood_map, cta_linking_id, cta_linked_id)
            add_neighbour(neighbourhood_map, cta_linked_id, cta_linking_id)
          end
        end
        Answer.all.each do |answer|
          if answer.call_to_action_id
            cta_linking_ids = Interaction.where(:resource_type => "Quiz", :resource_id => answer.quiz_id).pluck(:call_to_action_id)
            cta_linked_id = answer.call_to_action_id
            cta_linking_ids.each do |cta_linking_id|
              add_neighbour(neighbourhood_map, cta_linking_id, cta_linked_id)
              add_neighbour(neighbourhood_map, cta_linked_id, cta_linking_id)
            end
          end
        end
        neighbourhood_map
      end
    end

    # Internal: Recursive method to build the tree starting from a root node (tree variable).
    #
    # seen_nodes - Support variable consisting of a hash of { value => Node } elements. It should be empty at the beginning.
    # tree - Variable containing the call to actions tree. It should contain the root Node at the beginning.
    # cycles - Array containing the cycles, if there are any. A cycle is an array of integers corresponding to the call to action ids cycle path.
    # path - Support variable consisting of an array containing the cta ids path followed since the beginning. It should be empty at first and filled every recursion call.
    #
    # Returns the tree builded from the Node given at the beginning and the cycles array.
    def self.add_next_cta(seen_nodes, tree, cycles, path)
      cta = CallToAction.find(tree.value)
      if seen_nodes[tree.value].nil?
        seen_nodes.merge!({ tree.value => tree })
        if cta.interactions.any?
          cta.interactions.each do |interaction|
            children_cta_ids = InteractionCallToAction.where(:interaction_id => interaction.id).pluck(:call_to_action_id) + call_to_action_linked_to_answers(interaction.id)
            children_cta_ids.each do |children_cta_id|
              if path.include?(children_cta_id) # cycle
                cycles << path
                return seen_nodes[path[0]], cycles
              else
                if seen_nodes[children_cta_id].nil?
                  path << children_cta_id
                  cta_child_node = Node.new(children_cta_id)
                else
                  cta_child_node = seen_nodes[children_cta_id]
                end
                tree.children << cta_child_node unless is_a_child(tree, children_cta_id) # to avoid double adding
                add_next_cta(seen_nodes, cta_child_node, cycles, path)
              end
            end
          end
        end
      end
      return tree, cycles
    end

    def self.in_cycles(cta_id, cycles)
      cycles.each do |cycle|
        return true if cycle.include?(cta_id)
      end
      false
    end

    def self.is_a_child(node, cta_id)
      node.children.each do |child|
        return true if child.value == cta_id
      end
      false
    end

    def self.add_neighbour(neighbourhood_map, cta1, cta2)
      if neighbourhood_map[cta1].nil?
        neighbourhood_map[cta1] = Set.new [cta2]
      else
        neighbourhood_map[cta1].add(cta2)
      end
    end

    def self.build_reachable_cta_set(cta_id, reachable_cta_id_set, visited)
      neighbourhood_map = get_neighbourhood_map()
      neighbours = neighbourhood_map[cta_id]
      unless neighbours.nil?
        reachable_cta_id_set += neighbours
        visited << cta_id
        neighbours.each do |neighbour|
          unless visited.include?(neighbour)
            reachable_cta_id_set += build_reachable_cta_set(neighbour, reachable_cta_id_set, visited)
          end
        end
      end
      reachable_cta_id_set
    end

    def self.call_to_action_linked_to_answers(interaction_id)
      res = []
      interaction = Interaction.find(interaction_id)
      if interaction.resource_type == "Quiz"
        Answer.where(:quiz_id => interaction.resource_id).each do |answer|
          res << answer.call_to_action_id if answer.call_to_action_id
        end
      end
      res
    end

  end

  # Internal: Simple class to define a tree Node. A node value class can be anything.
  #
  # Examples
  #
  #    n = Node.new("Banana")
  #    # => #<LinkedCallToActionHelper::Node:0x007fd237682930 @value="Banana", @children=[]>
  #
  #    n.children.push(Node.new("Apple"))
  #    # => [#<LinkedCallToActionHelper::Node:0x007fd237637368 @value="Apple", @children=[]>]
  #
  #    n.children.push(Node.new("Pear"))
  #    # => [#<LinkedCallToActionHelper::Node:0x007fd237637368 @value="Apple", @children=[]>, 
  #          #<LinkedCallToActionHelper::Node:0x007fd237626040 @value="Pear", @children=[]>]
  #
  #    n
  #    # => #<LinkedCallToActionHelper::Node:0x007fd237669bb0 @value="Banana", 
  #          @children=[#<LinkedCallToActionHelper::Node:0x007fd237637368 @value="Apple", @children=[]>, 
  #                     #<LinkedCallToActionHelper::Node:0x007fd237626040 @value="Pear", @children=[]>]>
  class Node
    attr_accessor :value, :children

    def initialize(value = nil)
      @value = value
      @children = []
    end
  end

  def is_linking?(cta_id)
    CallToAction.find(cta_id).interactions.each do |interaction|
      return true if (InteractionCallToAction.find_by_interaction_id(interaction.id) || call_to_action_answers_linked_cta(cta_id).any?)
    end
    false
  end

  def is_linked?(cta_id)
    InteractionCallToAction.find_by_call_to_action_id(cta_id) || Answer.find_by_call_to_action_id(cta_id)
  end

  def call_to_action_answers_linked_cta(cta_id)
    res = []
    Interaction.where(:resource_type => "Quiz", :call_to_action_id => cta_id).each do |interaction|
      Answer.where(:quiz_id => interaction.resource_id).each do |answer|
        res << { answer.id => answer.call_to_action_id } if answer.call_to_action_id
      end
    end
    res
  end

  def save_interaction_call_to_action_linking(cta)
    ActiveRecord::Base.transaction do
      cta.interactions.each do |interaction|
        interaction.save!
        InteractionCallToAction.where(:interaction_id => interaction.id).destroy_all
        # if called on a new cta, linked_cta is a hash containing a list of { "condition" => <condition>, "cta_id" => <next cta id> } hashes
        links = interaction.resource.linked_cta rescue nil
        unless links
          if params["call_to_action"]["interactions_attributes"]
            params["call_to_action"]["interactions_attributes"].each do |key, value|
              links = value["resource_attributes"]["linked_cta"] if value["id"] == interaction.id.to_s
            end
          end
        end
        if links
          links.each do |key, link|
            if CallToAction.exists?(link["cta_id"].to_i)
              condition = link["condition"].blank? ? nil : { link["condition"] => link["parameters"] }.to_json
              InteractionCallToAction.create(:interaction_id => interaction.id, :call_to_action_id => link["cta_id"], :condition => condition )
            else
              cta.errors.add(:base, "Non esiste una call to action con id #{link["cta_id"]}")
            end
          end
        end
      end
      build_jstree_and_check_for_cycles(cta)
      if cta.errors.any?
        raise ActiveRecord::Rollback
      end
    end
    return cta.errors.empty?
  end

  def build_jstree_and_check_for_cycles(current_cta)
    current_cta_id = current_cta.id
    trees, cycles = CtaForest.build_trees(current_cta_id)
    data = []
    trees.each do |root|
      data << build_node_entries(root, current_cta_id) 
    end
    res = { "core" => { "data" => data } }
    if cycles.any?
      message = "Sono presenti cicli: \n"
      cycles.each do |cycle|
        cycle.each_with_index do |cta_id, i|
          message += (i + 1) != cycle.size ? "#{CallToAction.find(cta_id).name} --> " 
            : "#{CallToAction.find(cta_id).name} --> #{CallToAction.find(cycle[0]).name}\n"
        end
      end
      current_cta.errors[:base] << message
    end
    res.to_json
  end

  def build_node_entries(node, current_cta_id)
    if node.value == current_cta_id
      icon = "fa fa-circle"
    else
      cta_tags = get_cta_tags_from_cache(CallToAction.find(node.value))
      if cta_tags.include?('step')
        icon = "fa fa-step-forward"
      elsif cta_tags.include?('ending')
        icon = "fa fa-flag-checkered"
      else
        icon = "fa fa-long-arrow-right"
      end
    end
    res = { "text" => "#{CallToAction.find(node.value).name}", "icon" => icon }
    if node.children.any?
      res.merge!({ "state" => { "opened" => true }, 
                "children" => (node.children.map do |child| build_node_entries(child, current_cta_id) end) })
    end
    res
  end

end