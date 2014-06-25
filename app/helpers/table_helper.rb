require 'fandom_utils'

module TableHelper
  include FandomUtils
  include FilterHelper

  # A class that rappresent a filter field and its relation to ActiveRecord model
  class FieldDesc
    include ActiveAttr::TypecastedAttributes
    include ActiveAttr::MassAssignment
    include ActiveAttr::AttributeDefaults

    # human readable name of this field
    attribute :name, type: String
    # html id of this field
    attribute :id, type: String
    attribute :model, type: String
    attribute :column_name, type: String
    attribute :visible, type: Boolean
    
  end

  # Returns an Hash mapping field ids to FieldDesc. It should be overridden in children 
  def get_fields
    raise NotImplementedError.new
  end
  
  # Returns a json response to the page that request some data filter request
  def apply_filter
    offset = (params[:page].to_i - 1) * params[:perpage].to_i
    limit = params[:perpage]

    results = get_results(offset, limit)
    result_list = get_fields_to_show(results['elements'])
    
    data = Hash.new
    data['total'] = results['total']
    data['result'] = result_list
    respond_to do |format|
      format.json { render :json => data.to_json }
    end
  end

  # Returns an Hash with just the fields that should be shown to the user. It should be overridden in children. 
  def element_to_result(element)
    raise NotImplementedError.new
  end

  def get_fields_to_show(elements)
    results = Array.new
    elements.each do |e|
      result = element_to_result(e)
      results.push(result)        
    end
    results
  end

  # Perform the query applying the filters
  def get_results
      raise NotImplementedError.new
  end


end