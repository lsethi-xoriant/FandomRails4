#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class Easyadmin::CallToActionController < ApplicationController
  include EasyadminHelper
  include CallToActionHelper
  include RewardingSystemHelper
  include EventHandlerHelper
  include NoticeHelper
  include FilterHelper

  layout "admin"

  def clone
    clone_cta(params)
  end

  def restore_from_extra_fields(calltoaction)
    if calltoaction.extra_fields.present?
      calltoaction.extra_fields = JSON.parse(calltoaction.extra_fields)
      # TODO Ale
      extra_fields = calltoaction.extra_fields
      calltoaction.button_label = extra_fields["button_label"]
      calltoaction.alternative_description = extra_fields["alternative_description"]
      calltoaction.enable_for_current_user = extra_fields["enable_for_current_user"]
      calltoaction.shop_url = extra_fields["shop_url"]
    end
    calltoaction
  end

  def save_cta
    create_and_link_attachment(params[:call_to_action], nil)
    @cta = CallToAction.create(params[:call_to_action])
    if @cta.errors.any?
      @tag_list = params[:tag_list]
      @extra_options = params[:extra_options]
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

  def update_cta
    @cta = CallToAction.find(params[:id])
    create_and_link_attachment(params[:call_to_action], @cta)
    unless @cta.update_attributes(params[:call_to_action])
      @tag_list = params[:tag_list]
      @extra_options = params[:extra_options]
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
  end

  def show_details
    @current_cta = CallToAction.find(params[:id])

    @trivia_answer = Hash.new
    @versus_answer = Hash.new

    @current_cta.interactions.where("resource_type='Quiz'").each do |q|
      if q.resource.quiz_type == "TRIVIA"
        correct_count = UserInteraction.where("interaction_id = #{q.id} AND outcome::json#>>'{win, attributes, matching_rules}' ILIKE '%TRIVIA_CORRECT%'").count
        @trivia_answer[q.id] = {
          "answer_correct" => correct_count,
          "answer_wrong" => UserInteraction.where("interaction_id = #{q.id}").count - correct_count  
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

    render :partial => 'show_cta_details'
  end

  def update_activated_at
    cta = CallToAction.find(params[:id])
    cta.update_attribute(:activated_at, Time.parse(params["time"] + " UTC"))
    respond_to do |format|
      format.json { render :json => "calltoaction-update".to_json }
    end
  end

  def index_cta
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @cta_list = CallToAction.where("user_id IS NULL").page(page).per(per_page).order("activated_at DESC NULLS LAST")

    @page_size = @cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end
  
  def index_cta_template
    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    tag_template_id_list = Tag.where("name ilike 'template'").pluck("id") # should be only one
    cta_ids_with_tag_template = CallToActionTag.where("tag_id = ?", tag_template_id_list).pluck("call_to_action_id")
    @cta_template_list = CallToAction.where(:id => cta_ids_with_tag_template).page(page).per(per_page).order("activated_at DESC NULLS LAST")

    @page_size = @cta_template_list.num_pages
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
      @ctas = CallToAction.where("user_id IS NOT NULL and approved IS NULL").page(page).per(per_page).order("created_at DESC NULLS LAST")
    else
      @ctas = CallToAction.where("user_id IS NOT NULL and approved = ?", approvation_status).page(page).per(per_page).order("created_at DESC NULLS LAST")
    end

    @page_size = @ctas.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def filter

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @cta_list = CallToAction.where("user_id IS NULL").page(page).per(per_page).order("activated_at DESC NULLS LAST")
    @title_filter = params[:title_filter]
    @tag_list = params[:tag_list]

    if params[:commit] == "APPLICA FILTRO"
      
      cta_ids = get_tagged_objects(@cta_list, params[:tag_list], CallToActionTag, 'call_to_action_id', 'tag_id')

      where_conditions = "user_id IS NULL"
      where_conditions << " AND title ILIKE '%#{@title_filter}%'" unless @title_filter.nil?
      unless @tag_list.blank?
        where_conditions << (cta_ids.blank? ? " AND id IS NULL" : " AND id in (#{cta_ids.inspect[1..-2]})")
      end

      @cta_list = CallToAction.where(where_conditions).page(page).per(per_page).order("activated_at DESC NULLS LAST")
    end

    if params[:commit] == "RESET"
      @tag_list = nil
      @title_filter = nil
    end

    @page_size = @cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

    render template: "/easyadmin/call_to_action/index_cta"
    
  end

  def new_cta
    @cta = CallToAction.new
  end

  def edit_cta
    @cta = CallToAction.find(params[:id])
    if @cta.extra_fields.blank?
      @extra_options = {}
    else
      @extra_options = JSON.parse(@cta.extra_fields)
    end
    @tag_list_arr = Array.new
    @cta.call_to_action_tags.each { |t| @tag_list_arr << t.tag.name }
    @tag_list = @tag_list_arr.join(",")

    @cta = restore_from_extra_fields(@cta)
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

  def update_cta_status
    cta = CallToAction.find(params[:id])
    cta.update_attributes(activated_at: DateTime.now, approved: params[:approved])
    log_synced("moderated UGC content", approved: params[:approved], cta_id: cta.id, moderator_id: current_user.id)
    if cta.approved
      html_notice = render_to_string "/easyadmin/easyadmin_notice/_notice_ugc_approved_template", layout: false, 
                                      locals: { call_to_action_title: cta.title }, formats: :html
      user_upload_interaction = cta.user_upload_interaction
      if JSON.parse(Setting.find_by_key(NOTIFICATIONS_SETTINGS_KEY).value)['upload_approved'] != false
        notice = create_notice(:user_id => user_upload_interaction.user_id, :html_notice => html_notice, :viewed => false, :read => false)
        notice.send_to_user(request)
      end
      userinteraction, outcome = UserInteraction.create_or_update_interaction(user_upload_interaction.user_id, user_upload_interaction.upload_id, nil, nil)
      compute_save_and_notify_outcome(userinteraction, user_upload_interaction)
    end
    # TODO insert call to log moderation ugc event
    respond_to do |format|
      format.json { render :json => cta.to_json }
    end
  end
  
end