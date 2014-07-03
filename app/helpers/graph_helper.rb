require 'fandom_utils'
require "hamster"

module GraphHelper
  include FandomUtils

  # A class that rappresent a filter field and its relation to ActiveRecord model
  class TagsGraph
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    # nodes that belong to graph
    attribute :nodes #, type: Hash
  end
  
  class TagsNode
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults
    
    # key of node that corresponds to tag id 
    attribute :key, type: Integer
    # nodes linked (corresponds at tags linked to the current tag)
    attribute :links #, type: Array
  end
  
  def validate_tag_references(tag)    
    
    if tag.tags_tags.count > 0
      tags = Tag.includes(:tags_tags).where("tags_tags.other_tag_id IS NOT NULL")
      graph = create_graph(tags)    
      start_node = graph.nodes.fetch(tag.id, nil)
      seen_node_set = Hamster.set
      is_cyclic = is_cyclic_graph(graph, start_node, seen_node_set)
      return !is_cyclic
    else
      return true
    end
  end
  
  def is_cyclic_graph(graph, current_node, seen_node_set)
    if current_node.nil?
      return false
    elsif seen_node_set.include?(current_node.key)
      return true
    else
      recursive_set_nodes = seen_node_set.add(current_node.key)
      current_node.links.each do |l|
        debugger
        next_node = graph.nodes.fetch(l,nil)
        cyclic = is_cyclic_graph(graph, next_node, recursive_set_nodes)
        if cyclic
          return true
        end
      end
      return false
    end
  end
  
  def create_graph(elements)
    graph = TagsGraph.new({ :nodes => Hash.new })
    elements.each do |e|
      node = TagsNode.new({ :key => e.id, :links => Array.new })
      populate_node_links(node, e.tags_tags)
      graph.nodes[node.key] = node
    end
    return graph
  end
  
  def populate_node_links(node, links)
    links.each do |l|
      node.links.push(l.other_tag.id)
    end
  end

end