module DisneyHelper

  def get_disney_property() 
    $context_root || "disney-channel"
  end

  def get_disney_highlight_calltoactions(property)
    # Cached in index
    tag = Tag.find_by_name("highlight")
    if tag
      highlight_calltoactions_in_property = calltoaction_active_with_tag_in_property(tag, property, "DESC")
      meta_ordering = get_extra_fields!(tag)["ordering"]    
      if meta_ordering
        ordered_highlight_calltoactions = order_highlight_calltoactions_by_ordering_meta(meta_ordering, highlight_calltoactions_in_property)
      else
        highlight_calltoactions
      end
    else
      []
    end
  end

  def calltoaction_active_with_tag_in_property(tag, property, order)
    # Cached in index
    highlight_calltoactions = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.id = ?", tag.id)
    highlight_calltoactions_in_property = CallToAction.includes(:call_to_action_tags).active.where("call_to_action_tags.id = ? AND call_to_actions.id IN (?)", tag.id, highlight_calltoactions.map { |calltoaction| calltoaction.id }).order("activated_at #{order}")
  end

end
