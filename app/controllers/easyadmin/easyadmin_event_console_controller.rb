require 'fandom_utils'

class Easyadmin::EasyadminEventConsoleController < ApplicationController
  include EasyadminHelper
  include FandomUtils
  include FilterHelper

  layout "admin"
  
  before_filter :init
  
  def init
    @fields = Hash.new
    @fields['date'] = {"name" => "Data", "field" => "date", "model" => "userinteraction", "column_name" => "updated_at"}
    @fields['user'] = {"name" => "Utente", "field" => "email", "model" => "user", "column_name" => "email"}
    @fields['interaction'] = {"name" => "Interazione", "field" => "interaction", "model" => "interaction", "column_name" => "resource_type"}
  end
  
  def index
    @interaction_type_options = Interaction.uniq.pluck(:resource_type)
  end
  
  def filter_event
    count = Userinteraction.all.count
    off = (params[:page].to_i - 1) * params[:perpage].to_i
    lim = params[:perpage]
    
    if params[:conditions].blank?
      events = Userinteraction.limit(lim).offset(off).order("updated_at ASC")
    else
      conditions = JSON.parse(params[:conditions])
      events = build_query(conditions).limit(lim).offset(off).order("userinteractions.updated_at ASC")
    end
    
    results = Array.new
    events.each do |e|
      result = Hash.new
      result['date'] = e.updated_at.strftime("%d-%m-%Y %H:%M")
      result['email'] = e.user.email
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
    query = Userinteraction.includes(:user).includes(:interaction).includes(:answer)
    params.each do |compare|
      debugger
      query = query.where( get_active_record_expression(@fields[compare["field"]]['column_name'], compare["operand"], @fields[compare["field"]]['model']), compare["value"] )
    end
    
    return query   
  end

end