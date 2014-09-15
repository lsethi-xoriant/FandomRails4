class Sites::Ballando::IframeCheckController < ApplicationController
  
  layout "application_light"
  
  def show
    render template: "/iframe_check/show"
  end
  
  def get_check_template
    referrer = params[:referrer]
    cta = CallToAction.find_by_name("check_iframe")
    check_interaction = cta.interactions.first
    if !current_user
      template = render_to_string "/iframe_check/_not_logged_check", locals: { interaction: check_interaction }, layout: false, formats: :html
    elsif can_do_check(check_interaction, referrer)
      template = render_to_string "/iframe_check/_check_to_do", locals: { interaction: check_interaction }, layout: false, formats: :html
    elsif reached_cap
      template = render_to_string "/iframe_check/_cap_reached", locals: { interaction: check_interaction }, layout: false, formats: :html
    else
      template = render_to_string "/iframe_check/_check_already_done", locals: { interaction: check_interaction }, layout: false, formats: :html
    end
    respond_to do |format|
       format.json { render :json => template.to_json }
    end
  end
  
  def can_do_check(interaction, referrer)
    user_interaction = UserInteraction.where("interaction_id = ? AND user_id = ?", interaction.id, current_user.id).first
    if user_interaction.nil? || ( !reached_cap && !has_already_checked(interaction, referrer) ) 
      true
    else
      false
    end
  end
  
  def do_chek
    referrer = params[:referrer]
    cta = CallToAction.find_by_name("check_iframe")
    check_interaction = cta.interactions.first
    aux = {}
    if UserInteraction.where("interaction_id = ? AND user_id = ?", check_interaction.id, current_user.id).count > 0
      user_interaction = UserInteraction.where("interaction_id = ? AND user_id = ?", check_interaction.id, current_user.id).first
      aux = JSON.parse(user_interaction.aux)
      aux['referrer_list'] = aux['referrer_list'] + ",#{referrer}"
    else
      aux['referrer_list'] = "#{referrer}"
      #aux = "{referrer_list: '#{referrer}'}"
    end
    update_check_counter(check_interaction, aux.to_json)
    template = render_to_string "/iframe_check/_check_already_done", locals: { interaction: check_interaction }, layout: false, formats: :html 
    respond_to do |format|
       format.json { render :json => template.to_json }
    end
  end
  
  def update_check_counter(interaction, aux)
    create_or_update_interaction(current_user.id, interaction.id, nil, nil, aux)
  end
  
  def reached_cap
    check_counter = UserCounter.get_by_user(current_user)["DAILY"]["ALL_CHECK"]
    if check_counter.nil? || check_counter < DAILY_CHECK_CAP
      false
    else
      true
    end
  end
  
  def has_already_checked(interaction, referrer)
    user_interaction = UserInteraction.where("interaction_id = ? AND user_id = ?", interaction.id, current_user.id).first
    if user_interaction.nil? || !is_referrer_present(referrer, user_interaction.aux)
      false
    else
      true
    end
  end
  
  def is_referrer_present(referrer, aux)
    aux = JSON.parse(aux)
    aux['referrer_list'].split(",").include?(referrer)
  end
  
end

