require 'fandom_utils'
include FandomUtils

class SessionsController < Devise::SessionsController
  include FandomPlayAuthHelper
  
  prepend_before_filter :anchor_provider_to_current_user, only: :create, :if => proc {|c| current_user && env["omniauth.auth"].present? }
  skip_before_filter :iur_authenticate

  def anchor_provider_to_current_user
    # Assign the provier at the current user.
    current_user.logged_from_omniauth env["omniauth.auth"], params[:provider]
    flash[:notice] = "Agganciato #{ params[:provider] } all'utente"

    site = get_site_from_request(request)
    if site.force_facebook_tab && !request_is_from_mobile_device?(request)
      redirect_to site.force_facebook_tab
    else
      redirect_to "/"
    end
  end

  def omniauth_failure
    flash[:error] = "Errore nella sincronizzazione con il provider, assicurati di avere accettato i permessi."
    redirect_to "/users/sign_up"
  end

  # Authenticates and log in the user from the standard application form.
  def create_from_form
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_navigational_format?
    sign_in(resource_name, resource)
    fandom_play_login(resource)
    
    redirect_after_successful_login()
  end
  
  def valid_credentials?(user)
    user.nil? || !user.valid_password?(params['user']['password'])
  end

  # Authenticates and log in the user from the an OAuth service
  def create_from_oauth
    user, from_registration = User.not_logged_from_omniauth env["omniauth.auth"], params[:provider]
    if user.errors.any?
      redirect_to_registration_page(user)
    else
      sign_in(user)
      fandom_play_login(user)
    
      flash[:notice] = "from_registration" if from_registration
    
      if request.site.force_facebook_tab && !request_is_from_mobile_device?(request)
        redirect_to request.site.force_facebook_tab
      else
        redirect_after_successful_login()
      end
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
    session["oauth"]["params"] = env["omniauth.auth"].except("extra") # "extra" is removed to prevent cookie overflow
    session["oauth"]["params"]["provider"] = params[:provider]
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

