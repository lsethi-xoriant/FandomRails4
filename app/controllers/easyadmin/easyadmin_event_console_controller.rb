require 'fandom_utils'

class Easyadmin::EasyadminEventConsoleController < ApplicationController
  include EasyadminHelper
  include FandomUtils

  layout "admin"
  
  class FieldDescriptor  
    attr_accessor :name, :model, :association
    
    def initialize(name, model, association)
      @name = name
      @model = model
      @association = association
    end
    
  end
  
  @@CONSOLE_FIELDS_DESCRIPTORS = { 
    user: FieldDescriptor.new("email","User","user"), 
    interaction: FieldDescriptor.new("resource_type","Interaction","interaction"),
    date: FieldDescriptor.new("updated_at","Userinteraction","userinteractions")
  }
  
  def get_active_record_expression(name, operator, model)
    tablename = get_model_from_name(model).table_name
    operator_by_activerecord_expresson = { 
      FILTER_OPERATOR_CONTAINS => "#{tablename}.#{name} LIKE ?", 
      FILTER_OPERATOR_BETWEEN => "#{tablename}.#{name} <= ? AND #{@name} >= ?",
      FILTER_OPERATOR_LESS => "#{tablename}.#{name} < ?", 
      FILTER_OPERATOR_LESS_EQUAL => "#{tablename}.#{name} <= ?", 
      FILTER_OPERATOR_MORE => "#{tablename}.#{name} > ?",
      FILTER_OPERATOR_MORE_EQUAL => "#{tablename}.#{name} >= ?", 
      FILTER_OPERATOR_EQUAL => "#{tablename}.#{name} = ?" 
    }
    
    return operator_by_activerecord_expresson[operator]
  end

  def index_event
    @interaction_type_options = Interaction.uniq.pluck(:resource_type)
  end
  
  def filter_event
    count = Userinteraction.all.count
    off = (params[:page].to_i - 1) * params[:perpage].to_i
    lim = params[:perpage]
    
    if params[:conditions].blank?
      @events = Userinteraction.limit(lim).offset(off).order("updated_at ASC")
    else
      conditions = JSON.parse(params[:conditions])
      @events = build_query(conditions).limit(lim).offset(off).order("updated_at ASC")
    end
    
    results = Array.new
    @events.each do |e|
      result = Hash.new
      result['date'] = e.updated_at.strftime("%d-%m-%Y %H:%M")
      result['user'] = e.user.first_name + " " + e.user.last_name
      result['interaction'] = e.interaction.resource_type
      if e.answer && e.answer.correct? ? result['answer_correct'] = "ok" : result['answer_correct'] = "no"
      results.push(result)
      end  
    end

    data = Hash.new
    data['total'] = count
    data['result'] = results
    respond_to do |format|
      format.json { render :json => data.to_json }
    end
  end

  def build_query(params)
    fields = params.map { |element| element["field"] }.uniq
    query = Userinteraction
    
    fields.each do |field|
      #if get_model_from_name(@@CONSOLE_FIELDS_DESCRIPTORS[field.to_sym].model).table_name != "userinteractions"
      if @@CONSOLE_FIELDS_DESCRIPTORS[field.to_sym].association != "userinteractions"
        debugger
        query = query.includes(@@CONSOLE_FIELDS_DESCRIPTORS[field.to_sym].association.to_sym)  
      end
    end
    
    params.each do |compare|
      debugger
      query = query.where( get_active_record_expression(compare["field"],compare["operator"], @@CONSOLE_FIELDS_DESCRIPTORS[compare["field"].to_sym].model), compare["value"] )
    end
    
    return query   
  end

end