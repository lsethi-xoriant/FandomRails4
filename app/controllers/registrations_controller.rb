require 'fandom_utils'

class RegistrationsController < Devise::RegistrationsController

  include FandomUtils
  before_filter :fandom_before_filter
  before_action :configure_permitted_parameters

  skip_before_filter :require_no_authentication, :if => :stored_anonymous_user?
  skip_before_filter :verify_authenticity_token

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| permit(u) }
    devise_parameter_sanitizer.for(:sign_up) { |u| permit(u) }
  end

  def permit(u)
    u.permit(:first_name, :last_name, :username, :avatar, :avatar_selected, :avatar_selected_url, :email, :password, :password_confirmation, :privacy, :anonymous_id, :required_attrs)
  end

  def new
    resource = build_resource({})
    respond_with resource
  end

  def create
    sign_up_params["password_confirmation"] = sign_up_params["password"]
    required_attrs = ["privacy"]

    if stored_anonymous_user?
      self.resource = adjust_anonymous_user(sign_up_params.merge(required_attrs: required_attrs))
    else
      build_resource(sign_up_params.merge(required_attrs: required_attrs))
    end

    # Hooks provider data if the method has been invoked after an unsuccessful oauth
    append_provider(resource) if session["oauth"] && session["oauth"]["params"]

    if resource.save
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        change_global_user_id(resource.id)
        sign_up(resource_name, resource)

        cookies[:from_registration] = true 

        sign_up_params_for_logging = sign_up_params.clone
        sign_up_params_for_logging.delete('password')

        log_data = { 'form_data' => sign_up_params_for_logging, 'user_id' => current_user.id }
        log_synced("registration", adjust_user_and_log_data_with_utm(resource, log_data))

        set_account_up()
        respond_with resource, :location => after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      respond_with resource
    end
  end

  def update
    user_params = params[:user]
    required_attrs = ["username"]
    user_params = user_params.merge(required_attrs: required_attrs)

    current_user.update_with_password(user_params)

    if current_user.errors.blank?
      flash[:notice] = "Il tuo account è stato aggiornato"
      redirect_to "/users/edit"
    else
      render :edit
    end
  end

  def set_account_up    
    create_user_interaction_for_registration()
    SystemMailer.welcome_mail(current_user).deliver_now
  end

  protected

  def after_update_path_for(resource)
    "/profile/edit"
  end

  def append_provider(resource)
    omniauth = session["oauth"]["params"]
    provider = session["oauth"]["params"]["provider"]

    password = Devise.friendly_token.first(8)
    resource.password = password
    resource.password_confirmation = password

    resource.authentications.build(
        uid: omniauth['uid'],
        name: omniauth["info"]["name"],
        oauth_token: omniauth["credentials"]["token"],
        oauth_secret: (provider == "twitter" ? omniauth["credentials"]["secret"] : ""),
        oauth_expires_at: (provider == "facebook" ? Time.at(omniauth["credentials"]["expires_at"]) : ""),
        avatar: omniauth["info"]["image"],
        provider: provider,
        aux: session["oauth"]["params"].to_json
    )

    resource.avatar_selected_url = omniauth["info"]["image"]
    resource.avatar_selected = provider

    flash[:from_provider] = provider

  end

  def after_sign_up_path_for(resource)
    cookies[:from_registration] = true

    if cookies[:connect_from_page].blank?
      "/"
    else
      connect_from_page = cookies[:connect_from_page]
      cookies.delete(:connect_from_page)
      connect_from_page
    end
  end

end

