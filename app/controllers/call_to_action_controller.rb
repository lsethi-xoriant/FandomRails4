#!/bin/env ruby
# encoding: utf-8

class CallToActionController < ApplicationController
  # Libreria per la gestione del captcha, si occupa solamente di disegnarlo.
  require "noisy_image.rb"

  include ActionView::Helpers::SanitizeHelper

  # Per la gestione del captcha, genera un'immagine appoggiandosi alla libreria noisy_image e appoggiando
  # il valore in sessione.
  def code_image
      noisy_image = NoisyImage.new(8)
      session[:code] = noisy_image.code
      image = noisy_image.code_image
      send_data image, type: 'image/jpeg', disposition: 'inline'
  end

  def show
    @current_cta = CallToAction.find(params[:id])

    tag_list_arr = Array.new
    @current_cta.call_to_action_tags.each { |t| tag_list_arr << t.tag.text }
    @tag_list = tag_list_arr.join(",")

    if current_user
      subquery = Array.new
      current_user.user_interactions.includes(:interaction).select("interactions.call_to_action_id").where("user_id=?", current_user.id).each { |i| subquery.push(i.interaction.call_to_action_id) }
      @current_cta_related_list = CallToAction.where("id<>? AND id NOT IN (?)", @current_cta.id, (!subquery.blank? ? subquery.join(",") : -1)).limit(4)
    else
      @current_cta_related_list = CallToAction.where("id<>?", @current_cta.id).limit(4)
    end

    # Ho una sola iterazione di tipo commento per calltoaction.
    @inter_comment = @current_cta.interactions.where("resource_type='Comment'").first
    if @inter_comment
      @comment_must_be_approved =  @inter_comment.resource.must_be_approved?
      @user_comment = UserComment.new(comment_id: @inter_comment.resource.id)
      # Visualizzo il numero di commenti pubblicati e mostro solo gli ultimi 5.
      @comment_published_count = @inter_comment.resource.user_comments.publish.count
    else 
      @comment_published_count = -1
    end

    @inter_like = @current_cta.interactions.find_by_resource_type("Like") # TODO sempre visibile.
    @inter_share = @current_cta.interactions.where("resource_type='Share'") # TODO sempre visibile.
    @inter_download = @current_cta.interactions.find_by_resource_type("Download") # TODO sempre visibile.

    # Se ho delle interaction overvideo memorizzo delle informazioni base per poter successivamente 
    # far partire delle chiamate ajax e costruire la domanda.
    @overvideo_during_interaction_list = Hash.new
    @current_cta.interactions.where("when_show_interaction='OVERVIDEO_DURING'").order("seconds DESC").each do |i|
      @overvideo_during_interaction_list["#{i.id}"] = Hash.new
      
      # Traccio la tipologia di quiz e il secondo di apparizione, a seconda della tipologia ho un diverso template.
      if i.resource_type == "Check"
        @overvideo_during_interaction_list["#{i.id}"]["quiz_type"] = "CHECK"
      else
        quiz_type = i.resource_type == "Quiz" ? i.resource.quiz_type : "noquiz"
        @overvideo_during_interaction_list["#{i.id}"]["quiz_type"] = quiz_type
      end
      @overvideo_during_interaction_list["#{i.id}"]["seconds"] = i.seconds
    end

    if @current_cta.enable_disqus
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

  def get_closed_comment_published
    i = Interaction.find_by_call_to_action_id_and_resource_type(params[:calltoaction_id].to_i, "Comment")
    offset = params[:offset] - 10 > 0 ? (params[:offset] - 10) : 0
    risp = Hash.new
    i.resource.user_comments.publish.order("created_at ASC").offset(offset).limit(10).each do |uc|
      risp["#{ uc.id }"] = {
        "name" => (uc.user ? "#{ uc.user.first_name } #{ uc.user.last_name }" : "Anonimo"),
        "created_at" => uc.created_at,
        "text" => uc.text,
        "image" => (uc.user ? user_avatar(uc.user) : "")
      }
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end

  def index
  end

  def add_comment
    params[:user_comment] = params[:user_comment].merge(published_at: DateTime.now) unless Comment.find(params[:user_comment][:comment_id]).must_be_approved?
    params[:user_comment][:text] = sanitize(params[:user_comment][:text])
    
    unless params[:user_comment][:text].blank?
      if current_user
        @user_comment = UserComment.create(params[:user_comment].merge(user_id: current_user.id))
      elsif 
        # Verifico la correttezza del captcha inserito e salvato nella sessione.
        code = (JSON.parse session[:code]).join
        if code == params[:code]
          @user_comment = UserComment.create(params[:user_comment].merge(user_id: -1))
          @user_comment_captcha = true
        else
          @user_comment_captcha = false
        end
      end
    else
      @user_comment = UserComment.new
    end
  end

  def get_comment_published
    i = Interaction.find_by_call_to_action_id_and_resource_type(params[:calltoaction_id].to_i, "Comment")
    risp = Hash.new
    i.resource.user_comments.publish.order("created_at ASC").offset(params[:offset]).each do |uc|
      risp["#{ uc.id }"] = {
        "name" => (uc.user ? "#{ uc.user.first_name } #{ uc.user.last_name }" : "Anonimo"),
        "created_at" => uc.created_at,
        "text" => uc.text,
        "image" => (uc.user ? user_avatar(uc.user) : "")
      }
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end
  end

  def update_interaction
    interaction = Interaction.find(params[:id])
    user_interaction = UserInteraction.create_or_update_interaction(current_user.id, interaction.id)
    
    if current_user.anonymous?
      response['outcome'] = nil
    else
      UserCounter.update_counters(user_interaction)
      outcome = compute_and_save_outcome(user_interaction)
      if outcome.errors.any?
        # TODO: handle errors on rules through some notification
      end
      response['outcome'] = outcome
    end
    
    response["feedback"] = nil # TODO: render_to_string "/calltoaction/_overvideo_points_feedback", locals: { interaction_max_points: 0, points: 0, correct: nil }, layout: false, formats: :html 
    response["call_to_action_completed"] = call_to_action_completed?(interaction.call_to_action, useruser)
    respond_to do |format|
      format.json { render :json => response.to_json }
    end
  end

  def update_like
    i = Interaction.find(params[:interaction_id].to_i)
    ui = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, i.id)

    risp = Hash.new

    if ui   
      if ui.counter < 1
        ui = ui.update_attributes(user_id: current_user.id, interaction_id: i.id, counter: 1)
      else
        ui.update_attribute(:counter, 0)
        risp["interaction_save"] = false
      end
    else
      ui = UserInteraction.create(user_id: current_user.id, interaction_id: i.id)
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
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
        "share_content" => (render_to_string "/calltoaction/_share_free_footer", locals: { calltoaction: calltoaction }, layout: false, formats: :html),
        "overvideo_title" => (render_to_string "/calltoaction/_overvideo_play", locals: { calltoaction: calltoaction, calltoaction_index: params[:index] }, layout: false, formats: :html)
      }
    else
      response = {
        "share_content" => (render_to_string "/calltoaction/_share_footer", locals: { calltoaction: calltoaction }, layout: false, formats: :html),
        "overvideo_title" => (render_to_string "/calltoaction/_overvideo_play", locals: { calltoaction: calltoaction, calltoaction_index: params[:index] }, layout: false, formats: :html)
      }
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def calltoaction_overvideo_end

    if params[:type] == "extra"
      if mobile_device?
        render_calltoaction_overvideo_end_str = (render_to_string "/calltoaction/_overvideo_instant_win", 
          locals: { }, layout: false, formats: :html)
      else
        render_calltoaction_overvideo_end_str = (render_to_string "/calltoaction/_overvideo_instant_win", 
          locals: { }, layout: false, formats: :html)
      end     
    else
      calltoaction = CallToAction.active.find(params[:id])

      i = calltoaction.interactions.find_by_when_show_interaction("OVERVIDEO_END")

      if i.resource_type == "Quiz" && i.resource.quiz_type
        ui = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, i.id) if current_user

        render_calltoaction_overvideo_end_str = String.new
        if params[:end]
          calltoaction_correct_answer = i.resource.answers.find_by_correct(true)
          if calltoaction_correct_answer.calltoaction
            if mobile_device?
              render_calltoaction_overvideo_end_str = (render_to_string "/calltoaction/_overvideo_instant_win", 
                locals: { }, layout: false, formats: :html)
            else
              render_calltoaction_overvideo_end_str = (render_to_string "/calltoaction/_overvideo_instant_win", 
                locals: { }, layout: false, formats: :html)
            end
          end
        else
          calltoaction_question = i.resource.question

          calltoaction_answers = Hash.new
          if ui 
            calltoaction_user_answer = ui.answer_id
            user_interaction_points = ui.points + ui.added_points
          else
            calltoaction_user_answer = -1 
          end

          calltoaction_answers = Array.new
          i.resource.answers.each do |a|
            calltoaction_answers << a
          end

          interaction_points = i.points + i.added_points

          if mobile_device?
            render_calltoaction_overvideo_end_str = (render_to_string "/calltoaction/_overvideo_trivia", #_undervideo_trivia
              locals: { user_interaction_points: user_interaction_points, interaction_points: interaction_points, calltoaction_parent_id: calltoaction.id, calltoaction_question: calltoaction_question, calltoaction_answers: calltoaction_answers, calltoaction_user_answer: calltoaction_user_answer, interaction_overvideo_end_id: i.id }, layout: false, formats: :html)
          else
            render_calltoaction_overvideo_end_str = (render_to_string "/calltoaction/_overvideo_trivia", 
              locals: { user_interaction_points: user_interaction_points, interaction_points: interaction_points, calltoaction_parent_id: calltoaction.id, calltoaction_question: calltoaction_question, calltoaction_answers: calltoaction_answers, calltoaction_user_answer: calltoaction_user_answer, interaction_overvideo_end_id: i.id }, layout: false, formats: :html)
          end

        end
      end
    end

    respond_to do |format|
      format.json { render json: render_calltoaction_overvideo_end_str }
    end
  end

  # Return interaction data for generate quiz.
  def get_overvideo_interaction
    i = Interaction.find(params[:interaction_id].to_i)

    if i.resource_type == "Quiz"
      # Traccio se ho risposto o meno in precedenza al quiz.
      ui = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, i.id) if current_user

      risp = Hash.new
      risp["done"] = ui ? true : false
      risp['question'] = i.resource.question

      if i.resource.quiz_type == "VERSUS"
        # Il VERSUS contiene l'elenco delle risposte con relativo id, in aggiunta se ho risposto ho l'id della mia risposta
        # e le percentuali di risposta.
        risp["answers"] = Hash.new
        risp["user_answer"] = ui.answer_id if ui
        i.resource.answers.each do |a|
          ui_c = UserInteraction.where("interaction_id=? AND answer_id=?", i.id, a.id).count

          risp["answers"]["#{a.id}"] = { 
              "info" => ui ? (ui_c.to_f/i.user_interactions.count.to_f*100).round : "0",
              "text" => a.text,
              "image" => a.image.url
          }
        end
      elsif i.resource.quiz_type == "TRIVIA"
        # Il TRIVIA contiene l'elenco delle risposte con relativo id, in aggiunta se ho risposto ho l'id della mia risposta
        # e l'id della risposta corretta.
        risp["answers"] = Hash.new
        if ui
          risp["user_answer"] = ui.answer_id
          risp["correct_answer"] = i.resource.answers.find_by_correct(true).id # Attenzione a non passare la risposta corretta.
        end
        i.resource.answers.each do |a|
          risp['answers']["#{a.id}"] = a.text
        end
      end # i.resource.quiz_type == "VERSUS"/"TRIVIA"
    elsif i.resource_type == "Check"
      # Traccio se ho risposto o meno in precedenza al quiz.
      ui = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, i.id) if current_user

      risp = Hash.new
      risp["done"] = ui ? true : false
      risp['question'] = i.resource.description
      risp['check'] = i.resource.title
    end

    respond_to do |format|
      format.json { render :json => risp.to_json }
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

  # Update user answer.
  def update_answer
    i = Interaction.find(params[:interaction_id].to_i)
    ui = UserInteraction.find_by_user_id_and_interaction_id(current_user.id, params[:interaction_id].to_i)
    
    ans = Answer.find(params[:answer_id])

    risp = Hash.new
    if ui && (i.resource.quiz_type == "VERSUS" || ans.call_to_action)
      ui.update_attributes(answer_id: params[:answer_id], counter: (ui.counter + 1))
    elsif ui.blank?
      ui = UserInteraction.create(answer_id: params[:answer_id], user_id: current_user.id, interaction_id: params[:interaction_id]) 
      if (ui.points + ui.added_points) > 0
        if mobile_device?
          risp["undervideo_feedback"] = render_to_string "/calltoaction/_undervideo_points_feedback", locals: { calltoaction: i.call_to_action, interaction_max_points: (i.points + i.added_points), points: (ui.points + ui.added_points), correct: ui.answer.correct? }, layout: false, formats: :html 
        else
          risp["overvideo_feedback"] = render_to_string "/calltoaction/_overvideo_points_feedback", locals: { interaction_max_points: (i.points + i.added_points), points: (ui.points + ui.added_points), correct: ui.answer.correct? }, layout: false, formats: :html 
        end
      end
    end

    if i.resource.quiz_type == "VERSUS"
      i.resource.answers.each do |a|
        ui_c = UserInteraction.where("interaction_id=? AND answer_id=?", i.id, a.id).count
        risp["#{a.id}"] = (ui_c.to_f/i.user_interactions.count.to_f*100).round
      end
    elsif i.resource.quiz_type == "TRIVIA"
      risp["current_correct_answer"] = i.resource.answers.find_by_correct(true).id
      risp["next_calltoaction"] = ans.call_to_action if ans.call_to_action
    end

    risp["calltoaction_complete"] = calltoaction_done? i.call_to_action
    risp['points_updated'] = (get_current_contest_points current_user.id) if current_user

    respond_to do |format|
      format.json { render :json => risp.to_json }
    end  
  end  

  def check_level_and_badge_up
    risp = Hash.new

    respond_to do |format|
      format.json { render :json => risp.to_json }
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
        risp["undervideo_share_feedback"] = render_to_string "/calltoaction/_share_mobile_feedback", locals: { calltoaction: i.call_to_action }, layout: false, formats: :html 
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