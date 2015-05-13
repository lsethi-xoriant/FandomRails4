module TagHelper

  def filter_results(results, query)
    regexp = Regexp.new(query.split(/\W+/).map { |term| "(\\W+#{term}\\W+)" }.join("|"), Regexp::IGNORECASE)
    filtered_results = []
    results.each do |result|
      title = " #{result.title} "
      unless regexp.match(title).nil?
        filtered_results << result
      end
    end
    filtered_results
  end

  def construct_conditions_from_query(query, field)
    query.gsub!(/\W+/, ' ')
    conditions = ""
    query.split(" ").each do |term|
      if term.length > 3
        unless conditions.blank?
          conditions += " OR #{field} ILIKE #{ActiveRecord::Base.connection.quote("%#{term}%")}"
        else
          conditions += "#{field} ILIKE #{ActiveRecord::Base.connection.quote("%#{term}%")}"
        end
      end
    end
    conditions
  end
  
  def remove_excluded_elements(element_list, excluded_ids)
    element_list.each do |element|
      if excluded_ids.include? element.id
        element_list.delete(element)
      end
    end
    element_list
  end

  def get_ctas_with_tags_in_and(tag_ids, params = {})
    extra_key = get_extra_key_from_params(params)
    tag_ids_subselect = tag_ids.map { |tag_id| "(select call_to_action_id from call_to_action_tags where tag_id = #{tag_id})" }.join(' INTERSECT ')
    where_clause = get_cta_where_clause_from_params(params)
    ctas = CallToAction.includes(call_to_action_tags: :tag)
    if params.include?(:ical_start_datetime) || params.include?(:ical_end_datetime)
      ctas = ctas.joins("JOIN interactions ON interactions.call_to_action_id = call_to_actions.id").joins("JOIN downloads ON downloads.id = interactions.resource_id AND interactions.resource_type = 'Download'")
      ctas = add_ical_fields_to_where_condition(ctas, params)
    end
    if !tag_ids_subselect.empty?
      ctas = ctas.where("call_to_actions.id IN (#{tag_ids_subselect}) ")
    end
    if !where_clause.empty?
      ctas = ctas.where("#{where_clause}")
    end
    if params[:limit]
      offset, limit = params[:limit][:offset], params[:limit][:perpage]
      ctas = ctas.offset(offset).limit(limit)
    end
    
    if params[:order_string]
      ctas = ctas.order("#{params[:order_string]}")
    else
      ctas = ctas.order("activated_at DESC")
    end
    ctas = ctas.active.to_a
    # Move this code after cache block
    # if params.include?(:conditions) && params[:conditions][:exclude_cta_ids]
    #   remove_excluded_elements(ctas, params[:conditions][:exclude_cta_ids])
    # else
    #   ctas
    # end
  end
  
  def get_ctas_with_tags_in_or(tag_ids, params = {})
    extra_key = get_extra_key_from_params(params)
    #TODO: remove cache
    cache_short get_ctas_with_tags_cache_key(tag_ids, extra_key, "or") do
      where_clause = get_cta_where_clause_from_params(params)
      ctas = CallToAction.active.includes(call_to_action_tags: :tag)
      if params.include?(:ical_start_datetime) || params.include?(:ical_end_datetime)
        cta_id_to_ical_fields = get_cta_id_to_ical_fields(params) 
        ctas = ctas.where(id: cta_id_to_ical_fields) 
      end
      ctas = ctas.where("call_to_action_tags.tag_id IN (?) ", tag_ids)
      if !where_clause.empty?
        ctas = ctas.where("#{where_clause}")
      end
      if params[:limit]
        offset, limit = params[:limit][:offset], params[:limit][:perpage]
        ctas = ctas.offset(offset).limit(limit)
      end
      
      if params[:order_string]
        ctas.order("#{params[:order_string]}").to_a
      else
        ctas.order("activated_at DESC").to_a
      end

      # Move this code after cache block
      # if params.include?(:conditions) && params[:conditions][:exclude_cta_ids]
      #   remove_excluded_elements(ctas, params[:conditions][:exclude_cta_ids])
      # else
      #   ctas
      # end
    end
  end

  def get_tags_with_tags_in_and(tag_ids, params = {})
    extra_key = get_extra_key_from_params(params)
    where_clause = get_tag_where_clause_from_params(params)
    tags = Tag
    unless tag_ids.empty?
      tag_ids_subselect = tag_ids.map { |tag_id| "(select tag_id from tags_tags where other_tag_id = #{tag_id})" }.join(' INTERSECT ')
      tags = tags.where("id IN (#{tag_ids_subselect})")
    end
    if !where_clause.empty?
      tags = tags.where("#{where_clause}")
    end
    if params[:limit]
      offset, limit = offset, limit = params[:limit][:offset], params[:limit][:perpage]
      tags = tags.offset(offset).limit(limit)
    end
    tags.order("created_at DESC").to_a
  end
  
  def get_tags_with_tags(tag_ids, params = {})
    hidden_tags_ids = get_hidden_tag_ids
    where_clause = get_tag_where_clause_from_params(params)
    tags = Tag.includes(:tags_tags)
    
    if hidden_tags_ids.any? && tag_ids.empty?
      tags = tags.where("tags.id not in (#{hidden_tags_ids.join(",")})")
    elsif hidden_tags_ids.any? && !tag_ids.empty?
      tag_ids_subselect = tag_ids.map { |tag_id| "(select tag_id from tags_tags where other_tag_id = #{tag_id} AND tag_id not in (#{hidden_tags_ids.join(",")}) )" }.join(' INTERSECT ')
      tags = tags.where("tags.id in (#{tag_ids_subselect})")
    elsif hidden_tags_ids.empty? && !tag_ids.empty?
      tag_ids_subselect = tag_ids.map { |tag_id| "(select tag_id from tags_tags where other_tag_id = #{tag_id})" }.join(' INTERSECT ')
      tags = tags.where("tags.id in (#{tag_ids_subselect})")
    end
    
    if !where_clause.empty?
      tags.where("#{where_clause}")
    end
    if params[:limit]
      offset, limit = offset, limit = params[:limit][:offset], params[:limit][:perpage]
      tags = tags.offset(offset).limit(limit)
    end
    tags.order("created_at DESC").to_a
  end

  def get_tag_ids_for_cta(cta)
    #TODO: remove cache
    cache_short(get_tag_names_for_cta_key(cta.id)) do
      tags = {}
      cta.call_to_action_tags.each do |t|
        tags[t.tag.id] = t.tag.id
      end
      tags
    end
  end
  
  def get_tag_ids_for_tag(tag)
    cache_short(get_tag_names_for_tag_key(tag.id)) do
      tags = {}
      tag.tags_tags.each do |t| 
        tags[Tag.find(t.other_tag_id).id] = Tag.find(t.other_tag_id).id
      end
      tags  
    end
  end

  def get_tag_with_tag_about_call_to_action(calltoaction, tag_name)
    #TODO: remove cache
    cache_short get_tag_with_tag_about_call_to_action_cache_key(calltoaction.id, tag_name) do
      Tag.includes(tags_tags: :other_tag).includes(:call_to_action_tags).where("other_tags_tags_tags.name = ? AND call_to_action_tags.call_to_action_id = ?", tag_name, calltoaction.id).order("call_to_action_tags.updated_at DESC").to_a
    end
  end

  def get_tag_with_tag_about_tag(tag, parent_tag_name)
    #TODO: remove cache
    cache_short get_tag_with_tag_about_tag_cache_key(tag.id, parent_tag_name) do
      Tag.includes(tags_tags: :other_tag).includes(:tags_tags).where("other_tags_tags_tags.name = ? AND tags_tags.tag_id = ?", parent_tag_name, tag.id).order("tags_tags.updated_at DESC").to_a
    end
  end
  
  def get_tag_with_tag_about_reward(reward, tag_name)
    #TODO: remove cache
    cache_short get_tag_with_tag_about_reward_cache_key(reward.id, tag_name) do
      Tag.includes(tags_tags: :other_tag).includes(:reward_tags).where("other_tags_tags_tags.name = ? AND reward_tags.reward_id = ?", tag_name, reward.id).to_a
    end
  end


  def get_tags_with_tag(tag_name)
    cache_short get_tags_with_tag_cache_key(tag_name) do
      hidden_tags_ids = get_hidden_tag_ids
      if hidden_tags_ids.any?
        Tag.joins(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ? AND tags.id not in (?)", tag_name, hidden_tags_ids).to_a
      else
        Tag.joins(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ?", tag_name).to_a
      end
    end
  end
  
  def get_tags_with_tag_with_match(tag_name, query = "")
    conditions = construct_conditions_from_query(query, "tags.title")
    category_tag_ids = get_category_tag_ids()
    if conditions.empty?
      tags = Tag.includes(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ?", tag_name).order("tags.created_at DESC").to_a
    else
      tags = Tag.includes(:tags_tags => :other_tag ).where("other_tags_tags_tags.name = ? AND (#{conditions}) AND (tags.id in (?))", tag_name, category_tag_ids).order("tags.created_at DESC").to_a
    end
    filter_results(tags, query)
  end
  
  def get_tags_with_match(query = "")
    conditions = construct_conditions_from_query(query, "tags.title")
    category_tag_ids = get_category_tag_ids()
    if conditions.empty?
      tags = Tag.includes(:tags_tags).where("id in (?)", category_tag_ids).order("tags.created_at DESC").to_a
    else
      tags = Tag.includes(:tags_tags).where("(#{conditions}) AND (id in (?))", category_tag_ids).order("tags.created_at DESC").to_a
    end
    filter_results(tags, query)
  end
  
  def get_ctas_with_tag(tag_name)
    cache_short get_ctas_with_tag_cache_key(tag_name) do
      CallToAction.active.joins(:call_to_action_tags => :tag).where("tags.name = ? AND call_to_actions.user_id IS NULL", tag_name).to_a
    end
  end
  
  def get_user_ctas_with_tag(tag_name, offset = 0, limit = 6)
    cache_short get_user_ctas_with_tag_cache_key(tag_name) do
        CallToAction.active_with_media.joins(:call_to_action_tags => :tag).where("tags.name = ? AND call_to_actions.user_id IS NOT NULL", tag_name).offset(offset).limit(limit).to_a
    end
  end
  
  def get_ctas_with_tag_with_match(tag_name, query = "")
    conditions = construct_conditions_from_query(query, "call_to_actions.title")
    ctas = CallToAction.active.includes(call_to_action_tags: :tag).includes(:interactions).where("tags.name = ? AND (#{conditions})", tag_name).order("call_to_actions.created_at DESC").to_a
    filter_results(ctas, query)
  end
  
  def get_ctas_with_match(query = "")
    conditions = construct_conditions_from_query(query, "call_to_actions.title")
    if conditions.empty?
      ctas = CallToAction.active.includes(:interactions).where("user_id IS NULL").order("call_to_actions.created_at DESC").to_a
    else
      ctas = CallToAction.active.includes(:interactions).where("#{conditions} AND user_id IS NULL").order("call_to_actions.created_at DESC").to_a
    end
    filter_results(ctas, query)
  end

end