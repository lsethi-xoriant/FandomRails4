namespace :twitter_gallery do
  # require 'digest/md5'

  desc "Update the Twitter Gallery"
  task :update, [:app_root_path] => :environment do |t, args|
    # TODO: put this in constants
    TWITTER_SUBSCRIPTIONS_SETTINGS_KEY = 'twitter.subscriptions'

    # TODO: get this from deploy settings
    CONFIG = {
      consumer_key:    "BhvlJlFGoe8u1rbInMgPQstWO",
      consumer_secret: "VA9Nytkk2olT64s29DmsHSd9CIhHG4Q8fLPUZGW5R54EMoliB9",
    }

    # TODO: all interaction of type twitter should be found
    UPLOAD_INTERACTION_ID = 39
    # TODO: the tags should be get from the interaction
    TAGS = ['#violettamaxi']

    # TODO: iterate for every tenant
    TENANTS = ['fandom']

    #
    # Setup
    #

    client = Twitter::REST::Client.new(CONFIG)

    logger = Logger.new("#{args.app_root_path}/log/twitter_gallery.log")

    TENANTS.each do |tenant|
      switch_tenant(tenant)
      logger.info("handling tenant: #{tenant}")
      twitter_settings, twitter_settings_row = get_twitter_settings

      TAGS.each do |tag|
        update_gallery_tag(tag, twitter_settings, twitter_settings_row, client, logger)
      end
    end

  end

  def get_twitter_settings
    twitter_settings_row = Setting.find_by_key(TWITTER_SUBSCRIPTIONS_SETTINGS_KEY)
    if twitter_settings_row.nil?
      twitter_settings_row = Setting.create(key: TWITTER_SUBSCRIPTIONS_SETTINGS_KEY, value: {}.to_json)
    end

    twitter_settings = JSON.parse(twitter_settings_row.value)
    [twitter_settings, twitter_settings_row]
  end

  def update_gallery_tag(tag, twitter_settings, twitter_settings_row, client, logger)
      logger.info("handling tag: #{tag}")

      min_tag_id = twitter_settings[tag]["min_tag_id"] rescue nil

      if min_tag_id.nil?
        logger.info("first request for tag")
        tweets = client.search(tag).take(30)
      else
        tweets = client.search(tag, result_type: "recent", since_id: min_tag_id)
      end

      upload_interaction = Upload.find(UPLOAD_INTERACTION_ID)
      tweets.each do |tweet|
        if min_tag_id.nil? || tweet.id > min_tag_id
          min_tag_id = tweet.id
        end
        logger.info("generating UGC for tweet #{tweet.id}")
        clone_and_create_cta(upload_interaction, get_clone_params(tweet), nil)
      end

      (twitter_settings[tag] ||= {})["min_tag_id"] = min_tag_id
      twitter_settings_row.update_attributes(value: twitter_settings.to_json)
  end

  def get_clone_params(tweet)
    # TODO: twitter oauth has never been tested
    auth = Authentication.find_by_uid_and_provider(tweet.user.id, "twitter_#{$site.id}")
    if auth
      user_id = auth.user_id
    else
      user_id = anonymous_user.id 
    end
    { 
      "description" => tweet.text, 
      "user_id" => user_id 
    }
  end

end
