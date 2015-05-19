module ProfileHelper

  def not_logged_from_omniauth(auth, provider)  
    user_auth =  Authentication.find_by_provider_and_uid(provider, auth.uid);
    if user_auth
      # Ho gia' agganciato questo PROVIDER, mi basta recuperare l'utente per poi aggiornarlo.
      # Da tenere conto che vengono salvate informazioni differenti a seconda del PROVIDER di provenienza.
      user = user_auth.user
      user_auth.update_attributes(
          uid: auth.uid,
          name: (provider.include?("instagram") ? auth.info.nickname : auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          avatar: auth.info.image,
      )

      from_registration = false

    else
      # Verifico se esiste l'utente con l'email del provider selezionato.
      unless auth.info.email && (user = User.find_by_email(auth.info.email))
        password = Devise.friendly_token.first(8)
        user = User.new(
          password: password,
          password_confirmation: password,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          email: auth.info.email,
          avatar_selected: provider,
          privacy: nil # TODO: TENANT
          )
        from_registration = true
      else
        from_registration = false
      end 

      # Recupero l'autenticazione associata al provider selezionato.
      # Da tenere conto che vengono salvate informazioni differenti a seconda del provider di provenienza.
      user.authentications.build(
          uid: auth.uid,
          name: (provider.include?("instagram") ? auth.info.nickname : auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          provider: provider,
          avatar: auth.info.image,
          aux: auth.to_json
      )

      user.required_attrs = get_site_from_request(request)["required_attrs"]
      user.aux = JSON.parse(user.aux) if user.aux.present?
      user.save
    end 
    
    return user, from_registration
  end

  def user_for_registation_form()
    if current_user.aux
      aux = JSON.parse(current_user.aux)
      contest = aux[:contest]
      role = aux[:role]
    end

    {
      "day_of_birth" => current_user.day_of_birth,
      "month_of_birth" => current_user.month_of_birth,
      "year_of_birth" => current_user.year_of_birth,
      "gender" => current_user.gender,
      "location" => current_user.location, 
      "aux" => { 
        "contest" => contest,
        "terms" => role
      }
    }
  end

end
