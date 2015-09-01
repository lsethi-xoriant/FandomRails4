module ProfileHelper

  def birth_date_valid_for_contest?(contest_start_date, birth_date, age_limit = 18)
    (contest_start_date >= birth_date + age_limit.year)
  end

  def current_avatar size = "large"
    user_avatar(current_user, size)
  end

  def user_avatar user, size = "large"
    if !anonymous_user?(user) && user.avatar_selected_url.present?
      avatar = user.avatar_selected_url
      if (user.avatar_selected || "upload").include?("facebook")
        avatar = "#{user.avatar_selected_url}?width=200&height=200" #type=#{size}
      end
      avatar
    else
      anon_avatar()
    end
  end

  def anon_avatar
    if $site.id == "ballando"
      ActionController::Base.helpers.asset_path("ballando_anon.png")
    else
      assets_tag = Tag.find_by_name("assets")
      if assets_tag.present? && assets_tag.extra_fields.present? && assets_tag.extra_fields["anon_avatar"].present?
        assets_tag.extra_fields["anon_avatar"]["url"]
      else
        ActionController::Base.helpers.asset_path("anon.png")
      end
    end
  end

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
    levels.each do |key, level|
      cost = level["level"]["cost"].to_i
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

  def update_from_omniauth(auth, provider)
    from_registration = false
    user = current_user
    # When the provider is anchor to another user, I move it to current user
    user_auth = Authentication.find_by_provider_and_uid(provider, auth.uid);
    if user_auth
      user = user_auth.user if stored_anonymous_user?
      user_auth.update_attributes(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          avatar: auth.info.image,
          user_id: user.id
      )
    else
      if stored_anonymous_user?
        tmp_user = User.find_by_email(auth.info.email)
        if tmp_user.present?
          user = tmp_user
        else
          from_registration = true
        end
      end
      user_auth = user.authentications.build(
          uid: auth.uid,
          name: auth.info.name,
          oauth_token: auth.credentials.token,
          oauth_secret: (provider.include?("twitter") ? auth.credentials.secret : ""),
          oauth_expires_at: (provider == "facebook" ? Time.at(auth.credentials.expires_at) : ""),
          provider: provider,
          avatar: auth.info.image
      )
    end 

    if stored_anonymous_user?(user_auth.user)
      privacy = $site.id == "braun_ic" ? true : false
      user.assign_attributes({
          username: nil,
          first_name: auth.info.first_name,
          last_name: auth.info.last_name,
          email: auth.info.email,
          avatar_selected: provider,
          avatar_selected_url: auth.info.image,
          privacy: privacy
      })
      if user.valid?
        user.assign_attributes(anonymous_id: nil)
        sign_out(user)
      end
    end
    
    user.save
    [user, from_registration]
  end

  def create_from_omniauth(auth, provider)
    if provider.include?("facebook") || provider.include?("google_oauth2")
      expires_at = Time.at(auth.credentials.expires_at)
    end

    user_auth = Authentication.find_by_provider_and_uid(provider, auth.uid)
    if user_auth
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
      if auth.info.email.present?
        user = User.find_by_email(auth.info.email)
      end

      if !user
        password = Devise.friendly_token.first(8)
        privacy = $site.id == "braun_ic" ? true : false

        user = User.new(
            password: password,
            password_confirmation: password,
            first_name: auth.info.first_name,
            last_name: auth.info.last_name,
            email: auth.info.email,
            avatar_selected: provider,
            avatar_selected_url: auth.info.image,
            privacy: privacy
        )

        from_registration = true
      else
        from_registration = false
      end 

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
      user.save
    end 
    
    [user, from_registration]
  end

  def user_for_registation_form()
    if current_user
      {
        email: current_user.email,
        first_name: current_user.first_name, 
        last_name: current_user.last_name,
        day_of_birth: current_user.day_of_birth,
        month_of_birth: current_user.month_of_birth,
        year_of_birth: current_user.year_of_birth,
        newsletter: current_user.newsletter
      }
    else
      {}
    end
  end

end
