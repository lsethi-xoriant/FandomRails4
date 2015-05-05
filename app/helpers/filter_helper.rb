module FilterHelper
	
	# Get correct "where" condition starting from filter name
	#
	# name     - name of column filter name
	# operator - string of matching operator selected by user
	# model    - ActiveRecord model to which the field belongs to
	#
	def get_active_record_expression(name, operator, model)
    tablename = get_model_from_name(model).table_name
    operator_by_activerecord_expresson = { 
      FILTER_OPERATOR_CONTAINS => "#{tablename}.#{name} ILIKE ?", 
      FILTER_OPERATOR_BETWEEN => "#{tablename}.#{name} <= ? AND #{name} >= ?",
      FILTER_OPERATOR_LESS => "#{tablename}.#{name} < ?", 
      FILTER_OPERATOR_LESS_EQUAL => "#{tablename}.#{name} <= ?", 
      FILTER_OPERATOR_MORE => "#{tablename}.#{name} > ?",
      FILTER_OPERATOR_MORE_EQUAL => "#{tablename}.#{name} >= ?", 
      FILTER_OPERATOR_EQUAL => "#{tablename}.#{name} = ?" 
    }
    return operator_by_activerecord_expresson[operator]
  end

  # Internal: Get the active_record_relation objects tagged with tags having tag_names (in AND).
  #
  # active_record_relation - ActiveRecord objects
  # tag_names - array containing tag names
  # tagging_table - ActiveRecord model that links selected relation with tags
  # tagging_table_model_id_column_name - tagging_table selected relation attribute name
  # tagging_table_tag_id_column_name - tagging_table tag attribute name
  #
  # Examples
  #
  #    get_tagged_objects(CallToAction.where("created_at > '2015-01-01'"), ["violetta", "glam"], CallToActionTag, "call_to_action_id", "tag_id")
  #    # => [2333, 2398, 2403, 2408]
  #
  # Returns an array of ids
  def get_tagged_objects(active_record_relation, tag_names, tagging_table, tagging_table_model_id_column_name, tagging_table_tag_id_column_name)

    model_ids = Array.new
    active_record_relation.find_each do |model_instance|
      model_ids << model_instance.id
    end

    tag_ids = Array.new
    tag_names.split(",").each do |tag_name|
      tag = Tag.find_by_name(tag_name)
      tag_ids << tag.id if tag
    end

    tag_ids.each do |tag_id|
      model_ids_tagged = Array.new
      tagging_table.where("#{tagging_table_tag_id_column_name} = #{tag_id}").each do |mt|
        model_ids_tagged << mt[tagging_table_model_id_column_name]
      end
      model_ids = model_ids & model_ids_tagged
    end

    model_ids
  end
	
end
