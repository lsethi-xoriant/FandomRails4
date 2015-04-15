module LinkedCallToActionHelper

  # Internal: Custom class and methods useful to represent the set of trees containing a call 
  # to action following linking paths defined in interaction_call_to_actions table.
  # Based on Node class, every single tree is identified by its root Node.
  class CtaForest

    # Internal: Builds the graph of all the reachable call to actions from a given cta.
    # neighbourhood_map is a hash representing the undirected graph of all linked call to actions.
    # reachable_cta_id_set is the all reachable call to actions ids from starting call to action set.
    #
    # starting_cta_id - Call to action id to reach.
    #
    # Returns an array of trees containing the starting call to action and a boolean set to true if there are cycles.
    def self.build_trees(starting_cta_id)
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

  # Internal: Simple class to define a tree Node. A node value class can be anything.
  #
  # Examples
  #
  #    n = Node.new("Banana")
  #    # => #<LinkedCallToActionHelper::Node:0x007fd237682930 @value=5, @children=[]>
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

end