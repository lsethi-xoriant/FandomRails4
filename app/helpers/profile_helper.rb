module ProfileHelper

  def get_level_number()
    property = get_property()
    if property.present?
      property_name = property.name
    end

    levels, use_property = rewards_by_tag("level")
    use_property ? levels[property_name].count : levels.count
  end

  def get_current_level()
    property = get_property()
    if property.present?
      property_name = property.name
    end

    current_level = cache_short(get_current_level_by_user(current_user.id, property_name)) do
      levels, levels_use_prop = rewards_by_tag("level")
      if levels
        property_levels = prepare_levels_to_show(levels, property_name)

        level_in_progress = get_max_level_with_status(property_levels, "progress")

        current_level = level_in_progress || get_max_level_with_status(property_levels, "gained")
        current_level ? current_level : CACHED_NIL
      else
        CACHED_NIL
      end
    end
    cached_nil?(current_level) ? nil : current_level
  end

  def get_max_level_with_status(levels, status)
    max_level = nil
    max_cost = -1
    levels.each do  |key, level| 
      cost = level["cost"].to_i
      if level["status"] == status && (!max_level || cost > max_cost)
        max_level = level
        max_cost = cost
      end
    end
    max_level
  end

  def prepare_levels_to_show(levels, property_name)
    levels = levels[property_name]
    levels = order_rewards(levels.to_a, "cost")
    prepared_levels = {}
    if levels.present?
      index = 0
      level_before_point = 0
      level_before_status = nil
      levels.each do |level|
        if level_before_status.nil? || level_before_status == "gained"
          progress = calculate_level_progress(level, level_before_point, property_name)
          if progress >= 100
            level_before_status = "gained"
            prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => 100, "status" => level_before_status }
          else
            level_before_status = "progress"
            prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => progress, "status" => level_before_status }
          end
        else
          progress = 0
          level_before_status = "locked"
          prepared_levels["#{index+1}"] = {"level" => level, "level_number" => index+1, "progress" => progress, "status" => level_before_status }
        end
        index += 1
        level_before_point = level.cost
      end
    end
    prepared_levels
  end

  # Calculate a progress into a reward level.
  #   level          - the level to check progress
  #   starting_point - the cost of the preceding level
  def calculate_level_progress(level, starting_point, property_name)
    user_points = get_counter_about_user_reward(get_point_name(property_name))
    level.cost > 0 ? ((user_points - starting_point) * 100) / (level.cost - starting_point) : 100
  end

  def get_point_name(property_name)
    property_name == $site.default_property ? "point" : "#{property_name}-point"
  end

  def not_logged_from_omniauth(auth, provider)  
    expires_at = provider.include?("facebook") || provider.include?("google_oauth2") ? Time.at(auth.credentials.expires_at) : nil
    user_auth =  Authentication.find_by_provider_and_uid(provider, auth.uid);
    if user_auth
      # Ho gia' agganciato questo PROVIDER, mi basta recuperare l'utente per poi aggiornarlo.
      # Da tenere conto che vengono salvate informazioni differenti a seconda del PROVIDER di provenienza.
      user = user_auth.user
      user_auth.update_attributes(
          uid: auth.uid,
          name: (provider.include?("instagram") ? auth.info.nickname : auth.info.name),
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: expires_at,
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
          name: (provider.include?("instagram") ? auth.info.nickname : auth.info.name),
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: expires_at,
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
      aux = current_user.aux
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
