#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'

class Easyadmin::CallToActionController < Easyadmin::EasyadminController
  include EasyadminHelper
  include CallToActionHelper
  include RewardingSystemHelper
  include EventHandlerHelper
  include NoticeHelper
  include FilterHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    can? :manage, :user_call_to_actions
  end

  def clone
    authorize! :manage, :call_to_actions

    is_linking?(params[:id]) ? clone_linking_cta(params[:id]) : clone_cta(params[:id])
  end

  def restore_from_extra_fields(calltoaction)
    if calltoaction.extra_fields.present?
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
    authorize! :manage, :call_to_actions

    create_and_link_attachment(params[:call_to_action], nil)
    @cta = CallToAction.create(params[:call_to_action])

    comment_like_interaction = @cta.interactions.where(resource_type: "CommentLike").first
    if comment_like_interaction.present? && @cta.errors.empty? && comment_interaction = @cta.interactions.where(resource_type: "Comment").first
      comment_like_interaction.resource.update_attribute(:comment_id, comment_interaction.resource.id)
    end

    aux = {}

    if params[:call_to_action]["media_image_gravity_position"]
      aux["media_image_gravity_position"] = params[:call_to_action]["media_image_gravity_position"]
    end

    if params[:call_to_action]["interactions_attributes"]
      params[:call_to_action]["interactions_attributes"].each do |key, interaction_attributes|
        if interaction_attributes["gallery_type"] == "twitter"
          params[:call_to_action]["interactions_attributes"][key]["resource_attributes"]["title_needed"] = "0"
        end
      end
    end

    @cta.aux = aux

    save_interaction_call_to_action_linking(@cta) unless @cta.errors.any?

    if @cta.errors.any?
      @tag_list = params[:tag_list]
      @extra_options = params[:extra_options]
      render template: "/easyadmin/call_to_action/new_cta"
    else
      tag_list = params[:tag_list].split(",")
      @cta.call_to_action_tags.delete_all
      tags_with_error = []
      tag_list.each do |t|
        tag = Tag.find_by_name(t)
        tag = Tag.create(title: t, name: t, slug: t) if tag.blank?
        if tag.errors.any?
          tags_with_error << t
        else
          CallToActionTag.create(tag_id: tag.id, call_to_action_id: @cta.id)
        end
      end

      if tags_with_error.any?
        flash[:error] = "Tag non validi: #{tags_with_error.join(",")}"
      end

      flash[:notice] = "Contenuto generato correttamente"
      set_cta_updated_at(@cta)
      set_content_updated_at_cookie(@cta.updated_at)
      redirect_to "/easyadmin/cta/show/#{ @cta.id }"
    end
  end

  def update_cta
    if params[:part] == "user_cta_image" && params[:call_to_action]
      params[:call_to_action]['thumbnail'] = params[:call_to_action]['media_image']
    end

    @cta = CallToAction.find(params[:id])
    aux = @cta.aux || {}

    if params[:call_to_action]["media_image"] && ALLOWED_UPLOAD_MEDIA_TYPES.include?(params[:call_to_action]["media_type"])
      aux["aws_transcoding_media_status"] = "requested"
    end

    if params[:call_to_action]["media_image_gravity_position"]
      aux["media_image_gravity_position"] = params[:call_to_action]["media_image_gravity_position"]
    end

    if params[:call_to_action]["interactions_attributes"]
      params[:call_to_action]["interactions_attributes"].each do |key, interaction_attributes|
        if interaction_attributes["gallery_type"] == "twitter"
          params[:call_to_action]["interactions_attributes"][key]["resource_attributes"]["title_needed"] = "0"
        end
      end
    end

    @cta.aux = aux
    old_cta_updated_at = @cta.updated_at

    create_and_link_attachment(params[:call_to_action], @cta)
    updated_attributes = @cta.update_attributes(params[:call_to_action])
    saved_linking = save_interaction_call_to_action_linking(@cta)

    comment_like_interaction = @cta.interactions.where(resource_type: "CommentLike").first
    if comment_like_interaction.present? && @cta.errors.empty? && comment_interaction = @cta.interactions.where(resource_type: "Comment").first
      comment_like_interaction.resource.update_attribute(:comment_id, comment_interaction.resource.id)
    end

    unless updated_attributes && saved_linking && @cta.errors.messages.empty?
      @tag_list = params[:tag_list]
      @extra_options = params[:extra_options]
      render template: "/easyadmin/call_to_action/edit_cta"
    else
      if params[:tag_list]
        tag_list = params[:tag_list].split(",")
        @cta.call_to_action_tags.delete_all
        tags_with_error = []
        tag_list.each do |t|
          tag = Tag.find_by_name(t)
          tag = Tag.create(title: t, name: t, slug: t) if tag.blank?
          if tag.errors.any?
            tags_with_error << t
          else
            CallToActionTag.create(tag_id: tag.id, call_to_action_id: @cta.id)
          end
        end

        if tags_with_error.any?
          flash[:error] = "Tag non validi: #{tags_with_error.join(",")}"
        end
      end

      flash[:notice] = "CallToAction aggiornata correttamente"
      set_cta_updated_at(@cta)
      set_content_updated_at_cookie(@cta.updated_at) if @cta.updated_at != old_cta_updated_at
      redirect_to "/easyadmin/cta/show/#{@cta.id}"
    end
  end
  
  def show_cta
    @current_cta = CallToAction.find(params[:id])
    authorize! :manage, :call_to_actions if @current_cta.user_id.nil?

    tag_list_arr = []
    @current_cta.call_to_action_tags.each { |t| tag_list_arr << t.tag.name }
    @tag_list = tag_list_arr.join(", ")
  end

  def show_details
    authorize! :manage, :call_to_actions

    @current_cta = CallToAction.find(params[:id])
    interactions = @current_cta.interactions

    @shares = build_cta_detail(interactions, "Share", "share-counter")
    @plays = build_cta_detail(interactions, "Play", "play-counter")
    @likes = build_cta_detail(interactions, "Like", "like-counter")
    @downloads = build_cta_detail(interactions, "Download", "download-counter")
    @uploads = build_cta_detail(interactions, "Upload")
    @checks = build_cta_detail(interactions, "Check")
    @comments = build_cta_detail(interactions, "Comment")
    @links = build_cta_detail(interactions, "Link")

    @votes = Hash.new
    interaction_votes = @current_cta.interactions.where("resource_type='Vote'")
    if interaction_votes.any?
      interaction_votes.each_with_index do |interaction_vote, i|
        total = 0
        sum = 0
        user_interactions = UserInteraction.where(:interaction_id => interaction_vote.id)
        user_interactions.each do |user_interaction|
          total += 1
          sum += user_interaction.aux["vote"]
        end
        title = interaction_vote.resource.title
        @votes[i] = { "title" => title ? "VOTE [#{title}]" : "VOTE" , "total" => total, "mean" => sum.to_f/total }
      end
    end

    @trivia_answer = Hash.new
    @versus_and_test_answer = Hash.new

    @current_cta.interactions.where("resource_type='Quiz'").each do |q|
      if q.resource.quiz_type == "TRIVIA"
        correct_count = UserInteraction.where("interaction_id = #{q.id} AND outcome::json#>>'{win, attributes, matching_rules}' ILIKE '%TRIVIA_CORRECT%'").count
        @trivia_answer[q.id] = {
          "answer_correct" => correct_count,
          "answer_wrong" => UserInteraction.where("interaction_id = #{q.id}").count - correct_count  
        }
      else
        @versus_and_test_answer["#{ q.id }"] = Hash.new
        sum = 0
        q.resource.answers.each { |a| sum = sum + a.user_interactions.count }
        q.resource.answers.each do |v|
          @versus_and_test_answer["#{ q.id }"]["#{ v.id }"] = {
            "answer" => v.text,
            "perc" => ((v.user_interactions.count.to_f/sum.to_f*100))
          }
        end
      end
    end

    render :partial => 'show_cta_details'
  end

  def build_cta_detail(interactions, resource_type, reward_name_to_counter = nil)
    type_interactions_info = Hash.new
    type_interactions = interactions.where("resource_type='#{resource_type}'")
    if type_interactions.any?
      type_interactions.each_with_index do |interaction, i|
        total = 0
        if reward_name_to_counter
          user_interaction_outcomes = UserInteraction.where(:interaction_id => interaction.id).pluck(:outcome)
          user_interaction_outcomes.each do |out|
            total += JSON.parse(out)["win"]["attributes"]["reward_name_to_counter"]["#{reward_name_to_counter}"]
          end
          if resource_type == "Share"
            type_interactions_info[i] = { "total" => total, "providers" => interaction.resource.providers }
          else
            title = interaction.resource.title
            type_interactions_info[i] = { 
              "title" => title.blank? ? "#{resource_type.upcase}" : "#{resource_type.upcase} [#{title}]", 
              "total" => total
            }
          end
        else # infos are not in outcome field
          if resource_type == "Upload" or resource_type == "Link"
            UserInteraction.where(:interaction_id => interaction.id).pluck(:counter).each do |counter|
              total += counter
            end
            if resource_type == "Upload"
              title = CallToAction.find(interaction.resource.call_to_action_id).title
              type_interactions_info[i] = { 
                "title" => title.blank? ? "#{resource_type.upcase}" : "#{resource_type.upcase} [#{title}]", 
                "total" => total
              }
            else
              title = interaction.resource.title
              type_interactions_info[i] = { 
                "title" => title.blank? ? "#{resource_type.upcase}" : "#{resource_type.upcase} [#{title}]", 
                "total" => total
              }
            end
          elsif resource_type == "Comment"
            user_comment_interactions = UserCommentInteraction.where(:comment_id => interaction.resource_id)
            total = user_comment_interactions.count
            approved = user_comment_interactions.where(:approved => true).count
            type_interactions_info[i] = { "total" => total, "approved" => approved }
          else
            total = UserInteraction.where(:interaction_id => interaction.id).count
            title = interaction.resource.title
            type_interactions_info[i] = { 
              "title" => title.blank? ? "#{resource_type.upcase}" : "#{resource_type.upcase} [#{title}]", 
              "total" => total
            }
          end
        end
      end
    end
    type_interactions_info
  end

  def update_activated_at
    cta = CallToAction.find(params[:id])
    cta.update_column(:activated_at, time_parsed_to_utc(DateTime.parse(params["time"]).to_s))
    respond_to do |format|
      format.json { render :json => "calltoaction-update".to_json }
    end
  end

  def index_cta
    authorize! :manage, :call_to_actions

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    @cta_list = CallToAction.where("user_id IS NULL").page(page).per(per_page).order("activated_at DESC NULLS LAST")

    @page_size = @cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end
  
  def index_cta_template
    authorize! :manage, :call_to_actions

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    tag_template_id_list = Tag.where("name ilike 'template'").pluck("id") # should be only one
    cta_ids_with_tag_template = CallToActionTag.where("tag_id = ?", tag_template_id_list).pluck("call_to_action_id")
    @cta_list = CallToAction.where(:id => cta_ids_with_tag_template).page(page).per(per_page).order("activated_at DESC NULLS LAST")

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
      @ctas = CallToAction.where("user_id IS NOT NULL and approved IS NULL").page(page).per(per_page).order("created_at ASC NULLS LAST")
    else
      @ctas = CallToAction.where("user_id IS NOT NULL and approved = ?", approvation_status).page(page).per(per_page).order("created_at ASC NULLS LAST")
    end

    transcoding_settings = get_deploy_setting("sites/#{$site.id}/transcoding", false)
    
    if transcoding_settings
      @original_media_path = get_original_media_path(transcoding_settings)
    end
    @page_size = @ctas.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)
  end

  def get_original_media_path(transcoding_settings)
      region = transcoding_settings[:region]
      bucket = transcoding_settings[:bucket]
      output_folder = transcoding_settings[:s3_output_folder]
      "https://s3-#{region}.amazonaws.com/#{bucket}/#{output_folder}/original/"
  end

  def filter
    authorize! :manage, :call_to_actions

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    if params[:call_to_actions] == "all"
      @cta_list = CallToAction.where("user_id IS NULL").page(page).per(per_page).order("activated_at DESC NULLS LAST")
    elsif params[:call_to_actions] == "template"
      tag_template_id_list = Tag.where("name ilike 'template'").pluck("id") # should be only one
      cta_ids_with_tag_template = CallToActionTag.where("tag_id = ?", tag_template_id_list).pluck("call_to_action_id")
      @cta_list = CallToAction.where(:id => cta_ids_with_tag_template).page(page).per(per_page).order("activated_at DESC NULLS LAST")
    end

    @title_filter = params[:title_filter]
    @slug_filter = params[:slug_filter]
    @tag_list = params[:tag_list]

    if params[:commit] == "APPLICA FILTRO"
      
      cta_ids = get_tagged_objects(@cta_list, params[:tag_list], CallToActionTag, 'call_to_action_id', 'tag_id')

      where_conditions = params[:call_to_actions] == "all" ? "user_id IS NULL" : "id in (#{cta_ids_with_tag_template.join(",")})"
      where_conditions << " AND title ILIKE '%#{@title_filter.gsub("'", "''")}%'" unless @title_filter.blank?
      where_conditions << " AND slug ILIKE '%#{@slug_filter}%'" unless @slug_filter.blank?
      unless @tag_list.blank?
        where_conditions << (cta_ids.blank? ? " AND id IS NULL" : " AND id in (#{cta_ids.inspect[1..-2]})")
      end

      @cta_list = CallToAction.where(where_conditions).page(page).per(per_page).order("activated_at DESC NULLS LAST")
    end

    if params[:commit] == "RESET"
      @tag_list = nil
      @title_filter = nil
      @slug_filter = nil
    end

    @page_size = @cta_list.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

    if params[:call_to_actions] == "all"
      render template: "/easyadmin/call_to_action/index_cta"
    elsif params[:call_to_actions] == "template"
      render template: "/easyadmin/call_to_action/index_cta_template"
    end

  end

  def filter_ugc

    page = params[:page].blank? ? 1 : params[:page].to_i
    per_page = 20

    if params[:approvation_status] == 'approved'
      where_conditions = "user_id IS NOT NULL AND approved = 't'"
    elsif params[:approvation_status] == 'not_approved'
      where_conditions = "user_id IS NOT NULL AND approved = 'f'"
    else
      where_conditions = "user_id IS NOT NULL AND approved IS NULL"
    end

    @title_filter = params[:title_filter]
    @slug_filter = params[:slug_filter]
    @tag_list = params[:tag_list]
    @username_filter = params[:username_filter]
    @email_filter = params[:email_filter]

    if params[:commit] == "FILTRA" || params[:commit] == "ESPORTA"
      unless @tag_list.blank?
        cta_ids = get_tagged_objects(CallToAction.where(where_conditions), params[:tag_list], CallToActionTag, 'call_to_action_id', 'tag_id')
        where_conditions << (cta_ids.blank? ? " AND id IS NULL" : " AND id IN (#{cta_ids.join(',')})")
      end
      where_conditions << " AND title ILIKE '%#{@title_filter.gsub("'", "''")}%'" unless @title_filter.blank?
      where_conditions << " AND slug ILIKE '%#{@slug_filter}%'" unless @slug_filter.blank?
      user_where_conditions = "username ILIKE '%#{@username_filter}%'" unless @username_filter.blank?
      unless @email_filter.blank?
        user_where_conditions = 
          user_where_conditions.nil? ? "email ILIKE '%#{@email_filter}%'" 
          : user_where_conditions + " AND email ILIKE '%#{@email_filter}%'"
      end
      if user_where_conditions
        user_ids = User.where(user_where_conditions).pluck(:id)
        if user_ids.empty?
          where_conditions = "FALSE"
        else
          where_conditions << " AND user_id IN (#{user_ids.join(',')})" if user_ids
        end
      end
    end
    @ctas = CallToAction.where(where_conditions).page(page).per(per_page).order("activated_at ASC NULLS LAST")

    if params[:commit] == "ESPORTA"
      export_user_call_to_actions(CallToAction.where(where_conditions).order("activated_at ASC NULLS LAST").pluck(:id))
    end

    if params[:commit] == "RESET"
      @title_filter = @slug_filter = params[:tag_list] = @username_filter = @email_filter = nil
    end

    @page_size = @ctas.num_pages
    @page_current = page
    @start_index_row = page == 0 || page == 1 || page.blank? ? 1 : ((page - 1) * per_page + 1)

    if params[:commit] != "ESPORTA"
      cta_page = params[:approvation_status] != "to_approve" ? params[:approvation_status] : "to_be_approved"
      render template: "/easyadmin/call_to_action/index_user_cta_#{cta_page}" 
    end

  end

  def new_cta
    authorize! :manage, :call_to_actions

    @cta = CallToAction.new
  end

  def edit_cta
    @cta = CallToAction.find(params[:id])
    authorize! :manage, :call_to_actions if @cta.user_id.nil?
    if @cta.extra_fields.blank?
      @extra_options = {}
    else
      @extra_options = @cta.extra_fields
    end

    if @cta.aux && @cta.aux["media_image_gravity_position"]
      @cta.media_image_gravity_position = @cta.aux["media_image_gravity_position"]
    end

    @interaction_call_to_actions = []
    @cta.interactions.each do |interaction|
      InteractionCallToAction.where(:interaction_id => interaction.id).each do |icta|
        condition_hash = icta.condition || {}
        @interaction_call_to_actions += [
          [(condition_hash.keys.first || ""), (condition_hash.values.first || ""), (icta.call_to_action_id || "")]
        ]
      end
    end

    @tag_list_arr = Array.new
    @cta.call_to_action_tags.each { |t| @tag_list_arr << t.tag.name }
    @tag_list = @tag_list_arr.join(",")

    @cta = restore_from_extra_fields(@cta)

    render template: "/easyadmin/call_to_action/update_user_cta_image" if params[:part] == "user_cta_image"
  end

  def hide_cta
    cta = CallToAction.find(params[:id])
    if cta.activated_at.blank?
      risp = "active"
      cta.activated_at = DateTime.now.change(hour: 0).to_s
    else
      risp = "not-active"
      cta.activated_at = nil
    end
    cta.save
    set_content_updated_at_cookie(cta.updated_at)

    CallToActionTag.where(:call_to_action_id => cta.id).pluck(:tag_id).each do |tag_id|
      update_updated_at_recursive(tag_id, Time.now)
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end

  def update_cta_status
    cta = CallToAction.find(params[:id])
    activated_at = params[:approved] == 'false' ? nil : DateTime.now.to_s
    cta.activation_date_time = activated_at
    cta.approved = params[:approved]
    cta.save
    set_user_call_to_action_moderation_cookie()
    log_synced("moderated UGC content", approved: params[:approved], cta_id: cta.id, moderator_id: current_user.id)
    user_upload_interaction = cta.user_upload_interaction

    notifications_enable = Setting.find_by_key(NOTIFICATIONS_SETTINGS_KEY).value['upload_approved']

    property = get_property()
    if property
      property_name = property.name
    end

    if cta.approved
      userinteraction, outcome = create_or_update_interaction(User.find(user_upload_interaction.user_id), Interaction.where(:resource_type => 'Upload', :resource_id => user_upload_interaction.upload_id).first, nil, nil)
      text = "Complimenti! Il tuo contenuto \"#{cta.title}\" è stato approvato! Sarà visibile a breve."
    elsif cta.approved == false
      gallery_tag = get_cta_tag_tagged_with(cta, "gallery")
      extra_fields = gallery_tag.extra_fields rescue {}
      text = extra_fields["not_approved_text"]
    end

    if text && notifications_enable != false
      notice = create_notice(
        :user_id => user_upload_interaction.user_id, 
        :viewed => false, 
        :read => false, 
        :aux => {
          :ref_type => "call_to_action", 
          :ref_id => cta.id, 
          :property => property_name, 
          :text => text
        }
      )
    end
    # TODO insert call to log moderation ugc event
    respond_to do |format|
      format.json { render :json => cta.to_json }
    end
  end

  def send_reason_for_not_approving
    cta = CallToAction.find(params[:cta_id])
    aux = cta.aux || {}
    aux["reason_for_not_approving"] = params[:reason]
    cta.update_attribute(:aux, aux.to_json)
    filter_params = params.merge({ :controller => "call_to_action", :action => "filter_ugc" }).to_h
    filter_params["approvation_status"] = filter_params.delete "page"
    filter_params["page"] = filter_params.delete "page_number"
    filter_params["tag_list"] = filter_params.delete "tag_list_filter"
    filter_params["commit"] = "FILTRA"
    redirect_to filter_params
  end
end