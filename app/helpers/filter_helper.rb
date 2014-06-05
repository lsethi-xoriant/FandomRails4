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
	
end
