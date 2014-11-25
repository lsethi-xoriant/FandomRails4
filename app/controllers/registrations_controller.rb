require 'fandom_utils'

class RegistrationsController < Devise::RegistrationsController

  include FandomUtils
  before_filter :fandom_before_filter

  skip_before_filter :verify_authenticity_token

  def new
    resource = build_resource({})
    respond_with resource
  end

  def create
    build_resource(sign_up_params)

    # Aggancio i dati del provider se arrivo da un oauth non andato a buon fine.
    append_provider(resource) if session["oauth"] && session["oauth"]["params"]
    resource.required_attrs = get_site_from_request(request)["required_attrs"]

    if resource.save
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_up(resource_name, resource)

        if get_site_from_request(request)["anonymous_interaction"] && params[:user_interaction_info_list].present?
          JSON.parse(params[:user_interaction_info_list]).each do |user_interaction_info|
            begin
              interaction_id = user_interaction_info["interaction_id"]
              md5_to_validate_user_interaction = Digest::MD5.hexdigest("#{MD5_FANDOM_PREFIX}#{interaction_id}")
              if md5_to_validate_user_interaction == user_interaction_info["user_interaction"]["hash"] 
                interaction = Interaction.find(interaction_id)
                answer_id = user_interaction_info["user_interaction"]["answer"]["id"]
                create_or_update_interaction(resource, interaction, answer_id, false)
              end
            rescue Exception => exception
              log_error("registration with storage restore error", { exception: exception.to_s }) 
            end
          end
        end

        setUpAccount()

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

  def setUpAccount()
    SystemMailer.welcome_mail(current_user).deliver
  end

  protected

  def after_update_path_for(resource)
    "/profile/edit"
  end

  def append_provider resource
    omniauth = session["oauth"]["params"]
    provider = session["oauth"]["params"]["provider"]

    resource.authentications.build(
        uid: omniauth['uid'],
        name: omniauth["info"]["name"],
        oauth_token: omniauth["credentials"]["token"],
        oauth_secret: (provider == "twitter" ? omniauth["credentials"]["secret"] : ""),
        oauth_expires_at: (provider == "facebook" ? Time.at(omniauth["credentials"]["expires_at"]) : ""),
        provider: provider,
        aux: session["oauth"]["params"].to_json
    )
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

