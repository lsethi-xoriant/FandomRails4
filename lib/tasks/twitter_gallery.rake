namespace :twitter_gallery do

  desc "Update the Twitter Gallery"
  task :update, [:app_root_path] => :environment do |t, args|
    tenant_to_twitter_config = get_tenant_to_twitter_config(args.app_root_path)

    logger = Logger.new("#{args.app_root_path}/log/twitter_gallery.log")

    tenant_to_twitter_config.each do |tenant, twitter_config|
      logger.info("handling tenant: #{tenant}")

      switch_tenant(tenant)

      client = Twitter::REST::Client.new(twitter_config)

      twitter_settings, twitter_settings_row = get_twitter_settings

      get_upload_interaction_info_list().each do |info|
        update_gallery_tag(info, twitter_settings, client, logger)
      end

      twitter_settings_row.update_attributes(value: twitter_settings.to_json)
    end

  end

  def get_upload_interaction_info_list
    result = []
    Interaction.where(resource_type: 'Upload').each do |interaction|
      tag = get_from_hash_by_path(interaction.aux, 'configuration/twitter_tag/name', nil)
      unless tag.nil?
        registered_users_only = get_from_hash_by_path(interaction.aux, 'configuration/twitter_tag/registered_users_only', true)
        result << [interaction.resource, tag, registered_users_only]
      end
    end
    result
  end

  def get_tenant_to_twitter_config(app_root_path)
    deploy_settings = YAML.load_file("#{app_root_path}/config/deploy_settings.yml")
    sites = deploy_settings['sites'] rescue {}

    result = {}
    sites.each do |tenant, tenant_config|
      twitter_config = get_from_hash_by_path(deploy_settings['sites'][tenant], 'authentications/twitter', nil)
      unless twitter_config.nil?
        result[tenant] = {
          consumer_key: twitter_config['app_id'],
          consumer_secret: twitter_config['app_secret'],
        }
      end
    end
    result
  end

  def get_twitter_settings
    twitter_settings_row = Setting.find_by_key(TWITTER_SUBSCRIPTIONS_SETTINGS_KEY)
    if twitter_settings_row.nil?
      twitter_settings_row = Setting.create(key: TWITTER_SUBSCRIPTIONS_SETTINGS_KEY, value: {}.to_json)
    end

    twitter_settings = JSON.parse(twitter_settings_row.value)
    [twitter_settings, twitter_settings_row]
  end

  def update_gallery_tag(upload_interaction_info, twitter_settings, client, logger)
    upload_interaction, tag, registered_users_only = upload_interaction_info

    logger.info("handling tag: #{tag}")

    min_tag_id = twitter_settings[tag]["min_tag_id"] rescue nil

    if min_tag_id.nil?
      logger.info("first request for tag")
      tweets = client.search(tag).take(30)
    else
      tweets = client.search(tag, result_type: "recent", since_id: min_tag_id)
    end

    tweets.each do |tweet|
      if min_tag_id.nil? || tweet.id > min_tag_id
        min_tag_id = tweet.id
      end
      clone_params = get_clone_params(registered_users_only, tweet)
      unless clone_params.nil?
        logger.info("generating UGC for tweet #{tweet.id}")
        clone_cta(logger, tweet, upload_interaction, clone_params)
      end
    end

    (twitter_settings[tag] ||= {})["min_tag_id"] = min_tag_id
    logger.info("finished with tag: #{tag}")
  end

  def get_clone_params(registered_users_only, tweet)
    # TODO: twitter oauth has never been tested
    auth = Authentication.find_by_uid_and_provider(tweet.user.id, "twitter_#{$site.id}")
    if auth
      user_id = auth.user_id
    elsif registered_users_only
      return nil
    else
      user_id = anonymous_user.id 
    end
    { 
      "title" => tweet.text[0..100], 
      "description" => tweet.text, 
      "user_id" => user_id,
      "extra_fields" => {
        "twitter_avatar" => tweet.user.profile_image_url.to_s,
        "twitter_username" => tweet.user.screen_name
      }
    }
  end

  # TODO: this should be shared with instagram integration
  def clone_cta(logger, tweet, upload_interaction, clone_params)
      cloned_cta = clone_and_create_cta(upload_interaction, clone_params, nil)
      cloned_cta.build_user_upload_interaction(user_id: clone_params["user_id"], upload_id: upload_interaction.id)
      cloned_cta.aux = { "twitter_id" => tweet.id }
      cloned_cta.save
      if cloned_cta.errors.any?
        logger.error("error saving cta for tweet #{tweet.id}: #{cloned_cta.errors.full_messages}")
      end
  end

  # TODO: dirty workaround needed because clone_and_create_cta need to access current_user and that is not defined in rake tasks
  def current_user
    nil
  end

end
