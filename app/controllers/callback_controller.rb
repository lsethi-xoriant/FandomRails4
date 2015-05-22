#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'
require 'net/http'

class CallbackController < ApplicationController

  skip_before_filter :authenticate_admin
  before_filter :echo_service

  def echo_service
    headers = ""
    response_header = response.header
    unless response_header.empty?
      response_header.each_header do |key, value| 
        headers += "#{key} = #{value} - "
      end
    end
    log_info("callback method called", headers)
    logger.info(headers)
  end

  def instagram_new_tagged_media_callback
    # PubSubHubbub request
    # When we POST with the info above to create a new subscription, Instagram simultaneously submit a GET request 
    # to our callback URL with the following parameters:
    # hub.mode         - This will be set to "subscribe"
    # hub.challenge    - This will be set to a random string that our callback URL will need to echo back in order to verify we'd like to subscribe.
    # hub.verify_token - This will be set to whatever verify_token passed in with the subscription request. 
    #                    It's helpful to use this to differentiate between multiple subscription requests.
    if params["hub.mode"] && params["hub.mode"] == "subscribe"
      render json: params["hub.challenge"]
    else
      call_to_action_save = true
      ig_settings = get_deploy_setting("sites/#{$site.id}/authentications/instagram", nil)

      # Request body example:
      # [
      #   {
      #     "subscription_id": "1",
      #     "object": "user",
      #     "object_id": "1234",
      #     "changed_aspect": "media",
      #     "time": 1297286541
      #   },
      #   {
      #     "subscription_id": "2",
      #     "object": "tag",
      #     "object_id": "nofilter",
      #     "changed_aspect": "media",
      #     "time": 1297286541
      #   },
      #   ...
      # ]
      params["_json"].each do |subscription|

        if subscription["object"] == "tag"
          tag_name = subscription["object_id"]
          instagram_subscriptions_setting = Setting.find_by_key(INSTAGRAM_SUBSCRIPTIONS_SETTINGS_KEY)
          instagram_subscriptions_setting_hash = JSON.parse(instagram_subscriptions_setting.value)
          min_tag_id = instagram_subscriptions_setting_hash[tag_name]["min_tag_id"] rescue nil

          request_params = {
            "client_id" => "#{ig_settings["client_id"]}"
          }
          request_params.merge!({ "min_tag_id" => min_tag_id.to_i }) if min_tag_id
          url = "https://api.instagram.com/v1/tags/#{tag_name}/media/recent#{build_arguments_string_for_request(request_params)}"
          res = JSON.parse(open(url).read)
          res["data"].each do |media|
            auth = Authentication.find_by_uid_and_provider(media["user"]["id"], "instagram_#{$site.id}")
            if auth
              begin
                # secondary_id check necessary?
                img = open(media["images"]["standard_resolution"]["url"])
                created_time = Time.at(media["created_time"].to_i)
                call_to_action = CallToAction.new(
                  title: media["caption"]["text"], 
                  name: "instagram-tag-#{tag_name}-post-#{created_time.strftime("%Y-%m-%dT%H:%M:%S")}", 
                  # slug: , # if not set, it is the same as name
                  # enable_disqus: true, 
                  media_image: img, 
                  activation_date_time: Time.at(media["created_time"].to_i), 
                  # secondary_id: media["id"], 
                  media_type: "IMAGE", 
                  user_id: auth.user_id
                )

                # Anchor desired interactions to instagram call_to_action.
                # interaction = call_to_action.interactions.build(when_show_interaction: "SEMPRE_VISIBILE", points: 100)
                # interaction.resource = Check.new(title: "CHECK", description: "Foto scattata...")

                call_to_action_save = call_to_action_save && call_to_action.save
              rescue Exception
                call_to_action_save = false
              end
            end

            # Add tags?

          end
          min_tag_id = res["pagination"]["min_tag_id"]
          instagram_subscriptions_setting_hash[tag_name]["min_tag_id"] = res["pagination"]["min_tag_id"]
          instagram_subscriptions_setting.update_attribute(:value, instagram_subscriptions_setting_hash.to_json)
        end
      end
      render json: "OK"
    end
  end

end