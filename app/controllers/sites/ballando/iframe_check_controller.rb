class Sites::Ballando::IframeCheckController < ApplicationController
  
  layout "application_light"
  
  def show
    render template: "/iframe_check/show"
  end

  def get_check_interaction
    calltoaction = CallToAction.find_by_name("check_iframe")
    calltoaction.interactions.first
  end
  
  def get_check_template
    referrer = params[:referrer]
    check_interaction = get_check_interaction()

    if current_user
      user_interaction = current_user.user_interactions.find_by_interaction_id(check_interaction.id)
      template = render_to_string "/iframe_check/_logged_check", locals: { interaction: check_interaction, reached_cap: reached_cap(user_interaction), can_do_check: can_do_check(check_interaction, referrer, user_interaction) }, layout: false, formats: :html
    else
      template = render_to_string "/iframe_check/_not_logged_check", locals: { interaction: check_interaction }, layout: false, formats: :html
    end

    respond_to do |format|
       format.json { render :json => template.to_json }
    end
  end
  
  def can_do_check(interaction, referrer, user_interaction)
    user_interaction.nil? || !has_already_checked(interaction, referrer)
  end
  
  def do_check
    referrer = params[:referrer]
    check_interaction = get_check_interaction()

    if current_user
      user_interaction = current_user.user_interactions.find_by_interaction_id(check_interaction.id)
      
      user_can_do_check = can_do_check(check_interaction, referrer, user_interaction)
      user_reached_cap = reached_cap(user_interaction)

      if user_can_do_check && !user_reached_cap
        if user_interaction
          aux = JSON.parse(user_interaction.aux)
          aux['referrer_list'] = aux['referrer_list'] + ",#{referrer}"
          aux = update_counter_cap(aux)
        else
          aux = { 'referrer_list' => "#{referrer}" }
          aux = create_counter_cap(aux)
        end
        update_check_counter(check_interaction, aux.to_json)
        template = render_to_string "/iframe_check/_logged_check", locals: { interaction: check_interaction, reached_cap: false, can_do_check: false}, layout: false, formats: :html   
      else
        template = render_to_string "/iframe_check/_logged_check", locals: { interaction: check_interaction, reached_cap: user_reached_cap, can_do_check: user_can_do_check }, layout: false, formats: :html
      end
   
    else
      template = render_to_string "/iframe_check/_not_logged_check", locals: { interaction: check_interaction }, layout: false, formats: :html
    end


    respond_to do |format|
       format.json { render :json => template.to_json }
    end
  end
  
  def update_counter_cap(aux)
    counter = aux['check_counter'].split("::")
    if counter[0] == Date.today.to_s
      counter[1] = counter[1].to_i + 1
    else
      counter[0] = Date.today.to_s
      counter[1] = 0
    end
    aux['check_counter'] = counter.join("::")
    aux
  end
  
  def create_counter_cap(aux)
    counter = [Date.today.to_s, 1]
    aux['check_counter'] = counter.join("::")
    aux
  end
  
  def update_check_counter(interaction, aux)
    create_or_update_interaction(current_user, interaction, nil, nil, aux)
  end
  
  def reached_cap(user_interaction)
    if user_interaction.nil?
      false
    else
      check_info = JSON.parse(user_interaction.aux)
      check_counter = check_info['check_counter'].split("::")
      check_counter[0] == Date.today.to_s && check_counter[1].to_i >= BALLANDO_DAILY_CHECK_CAP
    end
  end
  
  def has_already_checked(interaction, referrer)
    user_interaction = current_user.user_interactions.find_by_interaction_id(interaction.id)
    user_interaction && is_referrer_present(referrer, user_interaction.aux)
  end
  
  def is_referrer_present(referrer, aux)
    aux = JSON.parse(aux)
    aux['referrer_list'].split(",").include?(referrer)
  end
  
end

