require 'fandom_utils'
include FandomUtils

class SessionsController < Devise::SessionsController
  include FandomPlayAuthHelper
  include ProfileHelper
  
  prepend_before_filter :anchor_provider_to_current_user, only: :create
  skip_before_filter :iur_authenticate
  skip_before_filter :require_no_authentication, :if => :stored_anonymous_user?

  def sign_in_as
    authorize! :manage, :users
    user = User.find(params[:id])
    sign_in(user)
    log_audit('sign in as', { 'original_user' => current_user.id, 'logged_in_user' => user.id})
    redirect_to root_url
  end

  def anchor_provider_to_current_user
    if !anonymous_user? && env["omniauth.auth"].present?
      # Assign the provier to the current user.
      update_from_omniauth(env["omniauth.auth"], params[:provider])

      site = get_site_from_request(request)
      if site.force_facebook_tab && !request_is_from_mobile_device?(request)
        redirect_to site.force_facebook_tab
      elsif cookies[:oauth_connect_from_page].present?
        oauth_connect_from_page = cookies[:oauth_connect_from_page]
        cookies.delete(:oauth_connect_from_page)
        redirect_to oauth_connect_from_page
      else
        if cookies[:calltoaction_id]
          connect_from_calltoaction = cookies[:calltoaction_id]
          cookies.delete(:calltoaction_id)
          redirect_to "/?calltoaction_id=#{connect_from_calltoaction}"
        else
          redirect_to "/"
        end
      end
    end
  end

  def omniauth_failure
    flash[:error] = "Errore nella sincronizzazione con il provider, assicurati di avere accettato i permessi."
    redirect_to "/users/sign_up"
  end

  # Authenticates and log in the user from the standard application form.
  def create_from_form
    if stored_anonymous_user?
      anonymous_user = current_user
      sign_out(current_user)
    end

    self.resource = warden.authenticate(auth_options)
    if self.resource.nil?
      begin
        self.resource = warden.authenticate!(auth_options)
      rescue Exception => e
        sign_in(anonymous_user)
        raise
      end
    else
    end

    set_flash_message(:notice, :signed_in) if is_navigational_format?

    sign_in(resource_name, resource)
    fandom_play_login(resource)
      
    redirect_after_successful_login()
  end
  
  def valid_credentials?(user)
    user.nil? || !user.valid_password?(params['user']['password'])
  end

  # Authenticates and log in the user from the an oauth service
  def create_from_oauth
    if stored_anonymous_user?
      user, from_registration = update_from_omniauth(env["omniauth.auth"], params[:provider])
    else
      user, from_registration = create_from_omniauth(env["omniauth.auth"], params[:provider])
    end

    if user.errors.any?
      redirect_to_registration_page(user)
    else
      change_global_user_id(user.id)
      sign_in(user)
      fandom_play_login(user)
    
      if from_registration
        log_data = { 'form_data' => env["omniauth.auth"], 'user_id' => current_user.id }
        log_synced("registration from oauth", adjust_user_and_log_data_with_utm(resource, log_data))

        set_account_up()
        cookies[:from_registration] = true 
      end

      if $site.force_facebook_tab && !request_is_from_mobile_device?(request)
        redirect_to request.site.force_facebook_tab
      else
        redirect_after_oauth_successful_login()
      end
    end
  end

  def set_account_up()
    create_user_interaction_for_registration()
    SystemMailer.welcome_mail(current_user).deliver_now
  end

  def redirect_after_oauth_successful_login()
    if cookies[:oauth_connect_from_page].present?
      oauth_connect_from_page = cookies[:oauth_connect_from_page]
      cookies.delete(:oauth_connect_from_page)
      redirect_to oauth_connect_from_page
    else
      redirect_after_successful_login()
    end
  end  

  def redirect_after_successful_login
    if cookies[:connect_from_page].blank?
      redirect_to "/"
    else
      redirect_to_original_page()
    end
  end
  
  def redirect_to_original_page
    connect_from_page = cookies[:connect_from_page]
    cookies.delete(:connect_from_page)
    redirect_to connect_from_page
  end
  
  def redirect_to_registration_page(user)
    session["oauth"] ||= {}
    session["oauth"]["params"] = env["omniauth.auth"] #.except("extra") to prevent cookie overflow
    session["oauth"]["params"]["provider"] = params[:provider]
    flash[:from_provider] = params[:provider]
    if cookies[:oauth_connect_from_page].present?
      cookies[:connect_from_page] = cookies[:oauth_connect_from_page]
    end
    render template: "/devise/registrations/new", :locals => { resource: user }   
  end

  def create
    if env["omniauth.auth"].nil?
      create_from_form()
    else
      create_from_oauth()
    end
  end
  
  def destroy
    fandom_play_logout()
    super
  end  
  
end

