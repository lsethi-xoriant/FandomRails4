require 'fandom_utils'

class RegistrationsController < Devise::RegistrationsController

  include FandomUtils
  before_filter :fandom_before_filter
  before_action :configure_permitted_parameters

  skip_before_filter :require_no_authentication, :if => :stored_anonymous_user?
  skip_before_filter :verify_authenticity_token

  def adjust_anonymous_user(params)
    resource = current_user
    resource.assign_attributes(email: nil, username: nil)
    resource.assign_attributes(params)
    if resource.valid?
      resource.assign_attributes(anonymous_id: nil)
      sign_out(current_user)
    end
    resource
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| permit(u) }
    devise_parameter_sanitizer.for(:sign_up) { |u| permit(u) }
  end

  def permit(u)
    u.permit(:first_name, :last_name, :username, :avatar, :avatar_selected, :avatar_selected_url, :email, :password, :password_confirmation, :privacy, :anonymous_id)
  end

  def new
    resource = build_resource({})
    respond_with resource
  end

  def create
    if stored_anonymous_user?
      self.resource = adjust_anonymous_user(sign_up_params)
    else
      build_resource(sign_up_params)
    end

    # Aggancio i dati del provider se arrivo da un oauth non andato a buon fine.
    append_provider(resource) if session["oauth"] && session["oauth"]["params"]

    if resource.save
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_up(resource_name, resource)

        # if params[:user_interaction_info_list].present? && params[:user_interaction_info_list].any?
        #   anonymous_interaction_map = {}

        #   JSON.parse(params[:user_interaction_info_list]).each_with_index do |user_interaction_info, index|
        #     begin
        #       interaction_id = user_interaction_info["interaction_id"]
        #       md5_to_validate_user_interaction = Digest::MD5.hexdigest("#{MD5_FANDOM_PREFIX}#{interaction_id}")
        #       if md5_to_validate_user_interaction == user_interaction_info["user_interaction"]["hash"] 
        #         interaction = Interaction.find(interaction_id)
        #         answer_id = user_interaction_info["user_interaction"]["answer"]["id"]
        #         aux = JSON.parse(user_interaction_info["user_interaction"]["aux"])
        #         if aux.has_key?("user_interactions_history") && aux["user_interactions_history"].present?
        #           user_interactions_history_updated = []
        #           aux["user_interactions_history"].each do |user_interaction_history|
        #             if anonymous_interaction_map.has_key?(user_interaction_history)
        #               user_interactions_history_updated = user_interactions_history_updated + [anonymous_interaction_map[user_interaction_history]]
        #             end
        #           end
        #           aux["user_interactions_history"] = user_interactions_history_updated
        #         end
        #         user_interaction, outcome = create_or_update_interaction(resource, interaction, answer_id, nil, aux.to_json)
        #         anonymous_interaction_map[index] = user_interaction.id
        #       end
        #     rescue Exception => exception
        #       log_error("registration with storage restore error", { exception: exception.to_s }) 
        #     end
        #   end
        # end

        setUpAccount()
        log_audit("registration", { 'form_data' => sign_up_params, 'user_id' => current_user.id })

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

