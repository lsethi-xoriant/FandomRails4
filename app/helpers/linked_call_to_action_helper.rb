require 'fandom_utils'

module LinkedCallToActionHelper

  # Based on Node class. A Tree is identified by its root node.

  class CtaForest

    # Build the graph of all the reachable call to actions and return an array of trees containing the starting
    # call to action and a boolean set to true if there are cycles.
    # neighbourhood_map -> hash representing the undirected graph of all linked call to actions.
    # reachable_cta_id_set -> set of all reachable call to actions ids from starting call to action.
    # cta_ids_to_check_for_cycles -> if set, array of call to action ids to test cyclicity

    def self.build_trees(starting_cta_id, cta_ids_to_check_for_cycles = nil)
      neighbourhood_map = {}
      InteractionCallToAction.all.each do |interaction_call_to_action|
        if interaction_call_to_action.interaction_id.present?
          cta_linking = Interaction.find(interaction_call_to_action.interaction_id).call_to_action_id
          cta_linked = interaction_call_to_action.call_to_action_id
          add_neighbour(neighbourhood_map, cta_linking, cta_linked)
          add_neighbour(neighbourhood_map, cta_linked, cta_linking)
        end
      end
      reachable_cta_id_set = build_reachable_cta_set(starting_cta_id, Set.new([starting_cta_id]), neighbourhood_map, [])
      seen_nodes = {}
      cycles = []
      reachable_cta_id_set.each do |cta_id|
        if seen_nodes[cta_id].nil? and !in_cycles(cta_id, cycles)
          tree = Node.new(cta_id)
          tree, cycles = add_next_cta(seen_nodes, tree, cycles, [cta_id])
        end
      end
      trees = []
      reachable_cta_id_set.each do |cta_id|
        if InteractionCallToAction.find_by_call_to_action_id(cta_id).nil? or (cycles.any? and cta_id == starting_cta_id) # add roots
          trees << seen_nodes[cta_id]
        end
      end
      return trees, cycles
    end

    # Recursive method to build the tree starting from a root node (tree variable).
    # For every descendant, a new node is created if it doesn't exist yet.

    def self.add_next_cta(seen_nodes, tree, cycles, path)
      cta = CallToAction.find(tree.value)
      if seen_nodes[tree.value].nil?
        seen_nodes.merge!({ tree.value => tree })
        if cta.interactions.any?
          cta.interactions.each do |interaction|
            children_cta_ids = InteractionCallToAction.where(:interaction_id => interaction.id).pluck(:call_to_action_id)
            children_cta_ids.each do |cta_id|
              if path.include?(cta_id) # cycle
                cycles << path
                return seen_nodes[path[0]], cycles
              else
                path << cta_id
                if seen_nodes[cta_id].nil?
                  cta_child = CallToAction.find(cta_id)
                  cta_child_node = Node.new(cta_child.id)
                else
                  cta_child_node = seen_nodes[cta_id]
                end
                tree.children << cta_child_node
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

    def self.add_neighbour(neighbourhood_map, cta1, cta2)
      if neighbourhood_map[cta1].nil?
        neighbourhood_map[cta1] = Set.new [cta2]
      else
        neighbourhood_map[cta1].add(cta2)
      end
    end

    def self.build_reachable_cta_set(cta_id, reachable_cta_id_set, neighbourhood_map, visited)
      neighbours = neighbourhood_map[cta_id]
      unless neighbours.nil?
        reachable_cta_id_set += neighbours
        visited << cta_id
        neighbours.each do |neighbour|
          unless visited.include?(neighbour)
            reachable_cta_id_set += build_reachable_cta_set(neighbour, reachable_cta_id_set, neighbourhood_map, visited)
          end
        end
      end
      reachable_cta_id_set
    end

  end

  class Node
    attr_accessor :value, :children

    def initialize(value = nil)
      @value = value
      @children = []
    end
  end

end