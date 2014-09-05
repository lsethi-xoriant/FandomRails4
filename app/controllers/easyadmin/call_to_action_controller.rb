#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class Easyadmin::CallToActionController < ApplicationController
  include EasyadminHelper
  include CallToActionHelper
  include RewardingSystemHelper

  layout "admin"

  def clone
    clone_cta(params)
  end
  
  def save_cta
    @cta = CallToAction.create(params[:call_to_action])
    if @cta.errors.any?
      @tag_list = params[:tag_list].split(",")

      render template: "/easyadmin/call_to_action/new_cta"     
    else

      tag_list = params[:tag_list].split(",")
      @cta.call_to_action_tags.delete_all
      tag_list.each do |t|
        tag = Tag.find_by_name(t)
        tag = Tag.create(name: t) unless tag
        CallToActionTag.create(tag_id: tag.id, call_to_action_id: @cta.id)
      end

      flash[:notice] = "CallToAction generata correttamente"
      redirect_to "/easyadmin/cta/show/#{ @cta.id }"
    end
  end

  def tag_cta_update
    calltoaction = CallToAction.find(params[:id])
    tag_list = params[:tag_list].split(",")

    calltoaction.call_to_action_tags.delete_all

    tag_list.each do |t|
      tag = Tag.find_by_name(t)
      tag = Tag.create(name: t) unless tag
      CallToActionTag.create(tag_id: tag.id, calltoaction_id: calltoaction.id)
    end
    flash[:notice] = "CallToAction taggata"
    redirect_to "/easyadmin/cta/tag/#{ calltoaction.id }"
  end
  
  def show_cta
    @current_cta = CallToAction.find(params[:id])

    tag_list_arr = Array.new
    @current_cta.call_to_action_tags.each { |t| tag_list_arr << t.tag.name }
    @tag_list = tag_list_arr.join(", ")

    @trivia_answer = Hash.new
    @versus_answer = Hash.new
    @current_cta.interactions.where("resource_type='Quiz'").each do |q|
      if q.resource.quiz_type == "TRIVIA"
        @trivia_answer["#{ q.id }"] = {
          "answer_correct" => q.resource.cache_correct_answer,
          "answer_wrong" => q.resource.cache_wrong_answer
        }
      elsif q.resource.quiz_type == "VERSUS"
        @versus_answer["#{ q.id }"] = Hash.new
        sum = 0
        q.resource.answers.each { |a| sum = sum + a.user_interactions.count }
        q.resource.answers.each do |v|
          @versus_answer["#{ q.id }"]["#{ v.id }"] = {
            "answer" => v.text,
            "perc" => ((v.user_interactions.count.to_f/sum.to_f*100))
          }
        end
      end
    end

  end
  
  def update_activated_at
    cta = CallToAction.find(params[:id])
    cta.update_attribute(:activated_at, Time.parse(params["time"]).to_date)
    respond_to do |format|
      format.json { render :json => "calltoaction-update".to_json }
    end
  end

  def index_cta
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @cta_list = CallToAction.where("user_generated = FALSE OR user_generated IS NULL").page(page).per(per_page).order("activated_at DESC NULLS LAST")

    @page_size = @cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end
  
  def index_user_cta_to_be_approved
    get_user_cta_with_status()
  end
  
  def index_user_cta_approved
    get_user_cta_with_status(true)
  end
  
  def index_user_cta_not_approved
    get_user_cta_with_status(false)
  end
  
  def get_user_cta_with_status(approvation_status = nil)
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20
    if approvation_status.nil?
      @ctas = CallToAction.where("user_generated = TRUE and approved IS NULL").page(page).per(per_page).order("created_at DESC NULLS LAST")
    else
      @ctas = CallToAction.where("user_generated = TRUE and approved = ?", approvation_status).page(page).per(per_page).order("created_at DESC NULLS LAST")
    end

    @page_size = @ctas.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def filter_calltoaction
    stream_call_to_action_to_render = CallToAction.where("LOWER(title) LIKE ?", "%#{ params[:filter].downcase }%").order("activated_at DESC").limit(5)

    render_calltoactions_str = ""
    stream_call_to_action_to_render.each do |calltoaction|
      render_calltoactions_str = render_calltoactions_str + (render_to_string "/easyadmin/call_to_action/_index_row", locals: { calltoaction: calltoaction }, layout: false, formats: :html)
    end

    respond_to do |format|
      format.json { render :json => render_calltoactions_str.to_json }
    end
  end

  def new_cta
    @cta = CallToAction.new
  end

  def edit_cta
    @cta = CallToAction.find(params[:id])

    @tag_list_arr = Array.new
    @cta.call_to_action_tags.each { |t| @tag_list_arr << t.tag.name }
    @tag_list = @tag_list_arr.join(",")
  end

  def hide_cta
    cta = CallToAction.find(params[:id])
    if cta.activated_at.blank?
      risp = "active"
      cta.update_attribute("activated_at", DateTime.now.change(hour: 0))
    else
      risp = "not-active"
      cta.update_attribute("activated_at", nil)
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end
  
  def update_cta
    @cta = CallToAction.find(params[:id])
    unless @cta.update_attributes(params[:call_to_action])
      @tag_list = params[:tag_list].split(",")
      render template: "/easyadmin/call_to_action/edit_cta"   
    else

      tag_list = params[:tag_list].split(",")
      @cta.call_to_action_tags.delete_all
      tag_list.each do |t|
        tag = Tag.find_by_name(t)
        tag = Tag.create(name: t) unless tag
        CallToActionTag.create(tag_id: tag.id, call_to_action_id: @cta.id)
      end

      flash[:notice] = "CallToAction aggiornata correttamente"
      redirect_to "/easyadmin/cta/show/#{ @cta.id }"
    end
  end
  
  def update_cta_status
    cta = CallToAction.find(params[:id])
    cta.update_attributes(activated_at: DateTime.now, approved: params[:approved])

    if cta.approved
      html_notice = render_to_string "/easyadmin/easyadmin_notice/_notice_ugc_approved_template", layout: false, formats: :html
      user_upload_interaction = cta.user_upload_interaction
      notice = Notice.create(:user_id => user_upload_interaction.user_id, :html_notice => html_notice, :viewed => false, :read => false)
      notice.send_to_user(request)
      userinteraction, outcome = UserInteraction.create_or_update_interaction(user_upload_interaction.user_id, user_upload_interaction.upload_id, nil, nil)
      compute_save_and_notify_outcome(userinteraction, user_upload_interaction)
    end
    # TODO insert call to log moderation ugc event
    respond_to do |format|
      format.json { render :json => cta.to_json }
    end
  end
  
end