#!/bin/env ruby
# encoding: utf-8

class CallToActionController < ApplicationController
  
  include ActionView::Helpers::SanitizeHelper
  include RewardingSystemHelper
  include CallToActionHelper
  include ApplicationHelper
  include CaptchaHelper

  def append_calltoaction
    render_calltoactions_str = String.new
    calltoactions = Array.new

    if params[:tag_id].present?
      stream_call_to_action_to_render = CallToAction.active.where("call_to_action_tags.tag_id=?", params[:tag_id]).offset(params[:offset]).limit(3)
    else
      stream_call_to_action_to_render = CallToAction.active.offset(params[:offset]).limit(3)
    end
    
    stream_call_to_action_to_render.each do |calltoaction|
      calltoactions << calltoaction
      render_calltoactions_str = render_calltoactions_str + (render_to_string "/call_to_action/_stream_single_calltoaction", locals: { calltoaction: calltoaction }, layout: false, formats: :html)
    end

    calltoactions_during_video_interactions_second = Hash.new
    calltoactions.each do |calltoaction|
      interactions_overvideo_during = calltoaction.interactions.find_all_by_when_show_interaction("OVERVIDEO_DURING")
      if(interactions_overvideo_during.any?)
        calltoactions_during_video_interactions_second[calltoaction.id] = Hash.new
        interactions_overvideo_during.each do |interaction|
          calltoactions_during_video_interactions_second[calltoaction.id][interaction.id] = interaction.seconds
        end
      end
    end

    response = Hash.new
    response = {
      calltoactions_during_video_interactions_second: calltoactions_during_video_interactions_second,
      calltoactions: calltoactions,
      html_to_append: render_calltoactions_str
    }
    
    respond_to do |format|
      format.json { render json: response.to_json }
    end
    
  end

  def show
    @calltoaction = CallToAction.find(params[:id])
    @calltoactions_during_video_interactions_second = initCallToActionsDuringVideoInteractionsSecond([@calltoaction])

    @calltoaction_comment_interaction = find_interaction_for_calltoaction_by_resource_type(@calltoaction, "Comment")
    
    @calltoactions_correlated = get_correlated_cta(@calltoaction)

    if page_require_captcha?(@calltoaction_comment_interaction)
      @captcha_data = generate_captcha_response
    end

=begin
    if @calltoaction.enable_disqus
      @disqus_requesturl = request.url
      comment_disqus = JSON.parse(open("https://disqus.com/api/3.0/posts/list.json?api_key=#{ ENV['DISQUS_PUBLIC_KEY'] }&forum=#{ ENV['DISQUS_SHORTNAME'] }&thread:link=#{ @disqus_requesturl }&limit=2").read)
      @disqus_cursor = comment_disqus["cursor"]
      comment_disqus = comment_disqus["response"]

      @disqus_hash = Hash.new
      comment_disqus.each do |comm|
        @disqus_hash[comm["id"]] = { text: comm["message"].html_safe, name: comm["author"]["name"], image: comm["author"]["avatar"]["small"]["permalink"],
                                                 created_at: comm["createdAt"] }
      end
    end
=end
  end

  def page_require_captcha?(calltoaction_comment_interaction)
    return !current_user && calltoaction_comment_interaction
  end
  
  def get_correlated_cta(calltoaction)
    tags_with_miniformat_in_calltoaction = get_tag_with_tag_about_call_to_action(calltoaction, "miniformat")
    if tags_with_miniformat_in_calltoaction.any?
      tag_id = tags_with_miniformat_in_calltoaction.first.id
      calltoactions = CallToAction.active.where("call_to_action_tags.tag_id=? and call_to_actions.id <> ?", tag_id, calltoaction.id).limit(3)
    else
       calltoactions = Array.new
    end
  end

  def next_disqus_page
    comment_disqus = JSON.parse(open("https://disqus.com/api/3.0/posts/list.json?api_key=#{ ENV['DISQUS_PUBLIC_KEY'] }&forum=#{ ENV['DISQUS_SHORTNAME'] }&thread:link=#{ params[:disqusurl] }&limit=2&cursor=#{ params[:disquscursor]}").read)
    disqus_cursor = comment_disqus["cursor"]
    comment_disqus = comment_disqus["response"]

    disqus_hash = Hash.new
    comment_disqus.each do |comm|
      disqus_hash[comm["id"]] = { text: comm["message"].html_safe, name: comm["author"]["name"], image: comm["author"]["avatar"]["small"]["permalink"],
                                                 created_at: comm["createdAt"] }
    end

    respond_to do |format|
      format.json { render :json => disqus_hash.to_json }
    end
  end

  def add_comment
    comment_resource = Interaction.find(params[:interaction_id]).resource

    published_at = comment_resource.must_be_approved ? nil : DateTime.now     
    user_text = params[:comment] # sanitize(params[:comment])
    
    response = Hash.new

    if current_user
      user_comment = UserComment.create(user_id: current_user.id, published_at: published_at, text: user_text, comment_id: comment_resource.id)
      response[:error] = user_comment.errors
    elsif 
      response[:captcha_check] = params[:stored_captcha] == Digest::MD5.hexdigest(params[:user_filled_captcha])
      if response[:captcha_check]
        user_comment = UserComment.create(user_id: current_user_or_anonymous_user.id, published_at: published_at, text: user_text, comment_id: comment_resource.id)
      end
    end

    respond_to do |format|
      format.json { render :json => response.to_json }
    end

  end

  def append_or_update_comments(interaction_id, &query_block)
    interaction = Interaction.find(interaction_id)

    response = Hash.new
    render_calltoactions_str = String.new

    comments_to_show = query_block.call(interaction, response)

    comments_to_show.each do |user_comment|
      render_calltoactions_str = render_calltoactions_str + (render_to_string "/call_to_action/_comment", locals: { user_comment: user_comment, new_comment_class: true }, layout: false, formats: :html)
    end

    response[:comments_to_append] = render_calltoactions_str

    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end

  def new_comments_polling
    append_or_update_comments(params[:interaction_id]) do |interaction, response|
      comments_to_show = interaction.resource.user_comments.publish.where("published_at > ?", params[:first_comment_shown_date]).order("published_at DESC")
      response[:first_comment_shown_date] = comments_to_show.any? ? comments_to_show.first.published_at : nil
      comments_to_show
    end
  end

  def append_comments
    append_or_update_comments(params[:interaction_id]) do |interaction, response|
      comments_to_show = interaction.resource.user_comments.publish.where("published_at < ?", params[:last_comment_shown_date]).order("published_at DESC").limit(10)
      response[:last_comment_shown_date] = comments_to_show.any? ? comments_to_show.last.published_at : nil
      response[:comments_to_append_counter] = comments_to_show.count
      comments_to_show
    end    
  end

  def update_interaction
    interaction = Interaction.find(params[:interaction_id])

    response = Hash.new

    if interaction.resource_type.downcase.to_sym == :quiz
      
      answer = Answer.find(params[:answer_id])
      user_interaction = UserInteraction.create_or_update_interaction(current_user_or_anonymous_user.id, interaction.id, answer.id)

      response["right_answer_response"] = user_interaction.answer.correct

      if answer.call_to_action
        response["next_call_to_action"] = {
          call_to_action_id: answer.call_to_action_id,
          video_url: answer.call_to_action.video_url,
          interaction_play_id: answer.call_to_action.interactions.find_by_resource_type("Play").id
        }
      end

    else
      user_interaction = UserInteraction.create_or_update_interaction(current_user_or_anonymous_user.id, interaction.id)
    end

    if current_user
      UserCounter.update_counters(user_interaction, current_user)
      # TODO: 
      outcome = compute_and_save_outcome(user_interaction)
      logger.info("rewards: #{outcome.reward_name_to_counter.inspect}")
      logger.info("unlocks: #{outcome.unlocks.inspect}")
      if outcome.errors.any?
        logger.error("errors in the rewarding system:")
        outcome.errors.each do |error|
          logger.error(error)
        end
      end
      # TODO: 
      response['outcome'] = outcome
      response["call_to_action_completed"] = call_to_action_completed?(interaction.call_to_action, current_user)
    else
      response['outcome'] = nil
    end

    response["main_reward_counter"] = get_counter_about_user_reward(params[:main_reward_name])

    if interaction.when_show_interaction == "SEMPRE_VISIBILE"
      response["feedback"] = render_to_string "/call_to_action/_undervideo_interaction", locals: { interaction: interaction, outcome: outcome }, layout: false, formats: :html 
    else
      response["feedback"] = render_to_string "/call_to_action/_feedback", locals: { outcome: outcome }, layout: false, formats: :html 
    end

    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end 

  def calltoaction_overvideo_end
    calltoaction = CallToAction.find(params[:calltoaction_id])
    interaction = calltoaction.interactions.find_by_when_show_interaction("OVERVIDEO_END")

    render_calltoaction_overvideo_end_str = String.new

    if interaction && (!interaction_for_next_calltoaction?(interaction) || (interaction_for_next_calltoaction?(interaction) && params[:right_answer_response].blank?))
   
      if current_user
        user_interaction = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, interaction.id)
      end

      render_calltoaction_overvideo_end_str = (render_to_string "/call_to_action/_overvideo_interaction", 
                locals: { interaction: interaction, user_interaction: user_interaction }, layout: false, formats: :html)

    end

    respond_to do |format|
      format.json { render json: render_calltoaction_overvideo_end_str }
    end
  end
 
  def interaction_for_next_calltoaction?(interaction)
    if interaction.resource_type.downcase.to_sym == :quiz
      interaction.resource.answers.where("call_to_action_id IS NOT NULL").any?
    else
      false
    end
  end

  def update_calltoaction_content
    response = Hash.new
    if params[:type]
      calltoaction = calltoaction_active_with_tag(params[:type], "DESC").find(params[:id])
    else
      calltoaction = CallToAction.active.find(params[:id])
    end

    if params[:type] == "youtube"
      response = {
        "share_content" => (render_to_string "/call_to_action/_share_free_footer", locals: { calltoaction: calltoaction }, layout: false, formats: :html),
        "overvideo_title" => (render_to_string "/call_to_action/_overvideo_play", locals: { calltoaction: calltoaction, calltoaction_index: params[:index] }, layout: false, formats: :html)
      }
    else
      response = {
        "share_content" => (render_to_string "/call_to_action/_share_footer", locals: { calltoaction: calltoaction }, layout: false, formats: :html),
        "overvideo_title" => (render_to_string "/call_to_action/_overvideo_play", locals: { calltoaction: calltoaction, calltoaction_index: params[:index] }, layout: false, formats: :html)
      }
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def get_overvideo_during_interaction
    interaction = Interaction.find(params[:interaction_id])

    response = Hash.new
    render_calltoaction_overvideo_end_str = String.new

    if current_user
      user_interaction = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, interaction.id)
    end

    render_calltoaction_overvideo_end_str = (render_to_string "/call_to_action/_overvideo_interaction", 
              locals: { interaction: interaction, user_interaction: user_interaction }, layout: false, formats: :html)

    response[:overvideo] = render_calltoaction_overvideo_end_str
    response[:interaction_done_before] = user_interaction.present?

    respond_to do |format|
      format.json { render json: response.to_json }
    end  
  end

  def update_check
    i = Interaction.find(params[:interaction_id].to_i)
    ui = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, params[:interaction_id].to_i)  
      UserInteraction.create(user_id: current_user.id, interaction_id: params[:interaction_id].to_i) unless ui
    respond_to do |format|
      format.json { render :json => "update-check".to_json }
    end  
  end

  def update_download
    i = Interaction.find(params[:interaction_id].to_i)
    ui = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, params[:interaction_id].to_i)  
    
    ui ? (ui.update_attribute(:counter, ui.counter + 1)) : (UserInteraction.create(user_id: current_user.id, interaction_id: params[:interaction_id].to_i))

    respond_to do |format|
      format.json { render :json => "update-download".to_json }
    end  
  end

  def share_free
    risp = Hash.new

    user_id = current_user ? current_user.id : -1 

    i = Interaction.find(params[:interaction_id].to_i)
    ui = UserInteraction.find_by_user_id_and_interaction_id(user_id, i.id)

    if ui
      ui.update_attribute(:counter, ui.counter + 1)
    else
      ui = UserInteraction.create(user_id: user_id, interaction_id: params[:interaction_id].to_i)
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end 
  end

  def share
    risp = Hash.new

    i = Interaction.find(params[:interaction_id].to_i)
    ui = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, i.id)

    if ui
      ui.update_attribute(:counter, ui.counter + 1)
    else
      ui = UserInteraction.create(user_id: current_user.id, interaction_id: params[:interaction_id].to_i)
      if mobile_device?
        risp["undervideo_share_feedback"] = render_to_string "/call_to_action/_share_mobile_feedback", locals: { calltoaction: i.call_to_action }, layout: false, formats: :html 
      end
      risp["points_for_user"] = ui.points
    end

    risp["calltoaction_complete"] = calltoaction_done? i.call_to_action

    if params[:provider] == "facebook" && current_user && current_user.facebook
      if Rails.env.production?
        current_user.facebook.put_wall_post(" ", { name: i.resource.message, description: i.resource.description, link: "#{ i.resource.link.blank? ? request.referer : i.resource.link }", picture: "#{ root_url }#{i.resource.picture.url}" })
      else
        current_user.facebook.put_wall_post(" ", { name: i.resource.message, description: i.resource.description, link: "#{ i.resource.link.blank? ? request.referer : i.resource.link }", picture: "#{ root_url }#{i.resource.picture.url}" })
        #current_user.facebook.put_wall_post("DEV #{ DateTime.now }", { name: i.resource.description })
      end
      risp['points_updated'] = (get_current_contest_points current_user.id) if current_user
      respond_to do |format|
        format.json { render :json => risp.to_json }
      end 
    # elsif params[:provier] = "twitter" && current_user && current_user.twitter
    #   current_user.twitter.update(i.resource.message)
    elsif params[:provider] == "email" && current_user
      if params[:share_email_address] =~ Devise.email_regexp

        SystemMailer.share_content_email(current_user, params[:share_email_address], i.call_to_action).deliver

        ui ? (ui.update_attribute(:counter, ui.counter + 1)) : (UserInteraction.create(user_id: current_user.id, interaction_id: params[:interaction_id].to_i))
        risp["email_correct"] = true
        risp['points_updated'] = (get_current_contest_points current_user.id) if current_user

        respond_to do |format|
          format.json { render :json => risp.to_json }
        end 
      else
        risp["email_correct"] = false
        respond_to do |format|
          format.json { render :json => risp.to_json }
        end
      end
    else
      respond_to do |format|
        format.json { render :json => "current-user-no-provider" }
      end
    end
  end

end
