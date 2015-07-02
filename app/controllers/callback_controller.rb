#!/bin/env ruby
# encoding: utf-8

require 'fandom_utils'
require 'net/http'

class CallbackController < ApplicationController

  skip_before_filter :authenticate_admin
  before_filter :echo_service

  def echo_service
    response_header = response.header
    log_info("callback method called", response_header)

    headers = []
    unless response_header.empty?
      response_header.each do |key, value| 
        headers << "#{key} = #{value}"
      end
    end
    headers = headers.join(" - ")
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

          interaction_id = instagram_subscriptions_setting_hash[tag_name]["interaction_id"]
          upload_interaction = Interaction.find(interaction_id)

          request_params = { "client_id" => "#{ig_settings["client_id"]}" }
          request_params.merge!({ "min_tag_id" => min_tag_id.to_i }) if min_tag_id
          url = "https://api.instagram.com/v1/tags/#{tag_name}/media/recent#{build_arguments_string_for_request(request_params)}"
          res = JSON.parse(open(url).read)
          headers = {'Content-Type' => 'application/json', 'Accept' => 'application/json'}

          res["data"].each do |media|
            cta_with_media_present = CallToAction.where("aux->>'instagram_media_id' = '#{media["id"]}'").first
            unless cta_with_media_present
              registered_users_only = upload_interaction.aux["configuration"]["registered_users_only"] rescue false
              clone_params = get_clone_params(registered_users_only, media)
              if clone_params.any?
                begin
                  cloned_cta = clone_and_create_cta(upload_interaction, clone_params, (upload_interaction.watermark rescue nil))
                  cloned_cta.build_user_upload_interaction(user_id: clone_params["user_id"], upload_id: upload_interaction.id)
                  cloned_cta.aux = { "instagram_media_id" => media["id"] }.to_json
                  cloned_cta.save
                end
              end
            end
          end
          min_tag_id = res["pagination"]["min_tag_id"]
          instagram_subscriptions_setting_hash[tag_name]["min_tag_id"] = res["pagination"]["min_tag_id"]
          instagram_subscriptions_setting.update_attribute(:value, instagram_subscriptions_setting_hash.to_json)
        end
      end
      render json: "OK"
    end
  end

  def get_clone_params(registered_users_only, media)
    clone_params = {}
    auth = Authentication.find_by_uid_and_provider(media["user"]["id"], "instagram_#{$site.id}")
    if auth
      user_id = auth.user_id
      clone_params.merge!({ 
        "title" => media["caption"]["text"], 
        "upload" => open(media["images"]["standard_resolution"]["url"]),
        "user_id" => user_id 
      })
    else
      unless registered_users_only
        clone_params.merge!({ 
          "title" => media["caption"]["text"], 
          "upload" => open(media["images"]["standard_resolution"]["url"]),
          "user_id" => anonymous_user.id 
        })
      end
    end
    clone_params
  end

end