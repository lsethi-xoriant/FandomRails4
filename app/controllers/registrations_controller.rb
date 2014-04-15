
class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token

  def new
    resource = build_resource({})
    respond_with resource
  end

  def create
    build_resource(sign_up_params)

    # Aggancio i dati del provider se arrivo da un oauth non andato a buon fine.
    append_provider(resource) if session["oauth"] && session["oauth"]["params"]

    if resource.save
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_up(resource_name, resource)
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

  protected

  def append_provider resource
    omniauth = session["oauth"]["params"]
    provider = session["oauth"]["params"]["provider"]

    resource.authentications.build(
        uid: omniauth['uid'],
        name: omniauth["info"]["name"],
        oauth_token: omniauth["credentials"]["token"],
        oauth_secret: (provider == "twitter" ? omniauth["credentials"]["secret"] : ""),
        oauth_expires_at: (provider == "facebook" ? Time.at(omniauth["credentials"]["expires_at"]) : ""),
        provider: provider
    )
  end

  def after_sign_up_path_for(resource)
    SystemMailer.welcome_mail(current_user).deliver
    flash[:notice] = "from_registration"
    return "/"
  end 

end

