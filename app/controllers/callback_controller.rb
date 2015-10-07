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
          upload = Interaction.find(interaction_id).resource

          request_params = { "client_id" => "#{ig_settings["client_id"]}" }
          request_params.merge!({ "min_tag_id" => min_tag_id.to_i }) if min_tag_id
          url = "https://api.instagram.com/v1/tags/#{tag_name}/media/recent#{build_arguments_string_for_request(request_params)}"
          res = JSON.parse(open(url).read)
          headers = { "Content-Type" => "application/json", "Accept" => "application/json" }
          media_already_processed = []

          res["data"].each do |media|
            cta_with_media_present = CallToAction.where("aux->>'instagram_media_id' = '#{media["id"]}'").first
            if !cta_with_media_present && !media_already_processed.include?(media["id"])
              media_already_processed << media["id"]
              registered_users_only = upload.aux["configuration"]["registered_users_only"] rescue false
              clone_params = get_instagram_clone_params(registered_users_only, media)
              if clone_params.any?
                begin
                  cloned_cta = clone_and_create_cta(upload, clone_params, (upload.watermark rescue nil))
                  cloned_cta.build_user_upload_interaction(user_id: clone_params["user_id"], upload_id: upload.id)
                  cloned_cta.aux = { "instagram_media_id" => media["id"] }
                  cloned_cta.save
                end
              end
            end
          end
          new_min_tag_id = res["pagination"]["min_tag_id"]
          instagram_subscriptions_setting_hash[tag_name]["min_tag_id"] = new_min_tag_id
          instagram_subscriptions_setting.update_attribute(:value, instagram_subscriptions_setting_hash.to_json)
        end
      end
      render json: "OK"
    end
  end

  def get_instagram_clone_params(registered_users_only, media)
    auth = Authentication.find_by_uid_and_provider(media["user"]["id"], "instagram_#{$site.id}")
    if !auth && registered_users_only
      return {}
    else
      user_id = auth ? auth.user_id : anonymous_user.id
      return { 
        "title" => media["caption"]["text"][0..100], 
        "upload" => open(media["images"]["standard_resolution"]["url"]),
        "user_id" => user_id, 
        "extra_fields" => { "layout" => "instagram", "instagram_avatar" => media["user"]["profile_picture"], "instagram_username" => media["user"]["username"] }
      }
    end
  end

  def facebook_page_feed_callback

    if params["hub.mode"] && params["hub.mode"] == "subscribe"
      render json: params["hub.challenge"]
    else
      call_to_action_save = true

      # Request body example:
      # {
      #   object: "page", 
      #   entry: [
      #     changes: [
      #       field: "feed", 
      #       value: {
      #         created_time: "1444051456", 
      #         item: "status" / "photo" / "video", 
      #         link: "https://[...].jpg", 
      #         message: "Look at this!", 
      #         photo_id: "1025277764189605", 
      #         post_id: "1024018720982176_1025276557523059", 
      #         published: "1", 
      #         sender_id: "1024018720982176", 
      #         sender_name: "Page title", 
      #         verb: "add"
      #       }
      #     ], 
      #     id: "1024018720982176", 
      #     time: "1444051456"
      #   ]
      # }
      facebook_subscriptions_setting = Setting.find_by_key(FACEBOOK_SUBSCRIPTIONS_SETTINGS_KEY)
      facebook_subscriptions_setting_hash = JSON.parse(facebook_subscriptions_setting.value)

      params["body"]["entry"].each do |entry|

        page_id = entry["id"]
        interaction_id = facebook_subscriptions_setting_hash[page_id]["interaction_id"]
        upload = Interaction.find(interaction_id).resource

        entry["changes"].each do |change|

          post = change["value"]
          if post["published"].to_i == 1
            cta_with_post_present = CallToAction.where("aux->>'facebook_post_id' = '#{post["post_id"]}'").first
            clone_params = get_facebook_clone_params(post, upload.call_to_action)

            if cta_with_post_present
              begin
                clone_params["media_image"] = clone_params.delete("upload")
                clone_params["thumbnail"] = clone_params["media_image"]
                clone_params["aux"] = cta_with_post_present.aux.merge({ "facebook_params" => change })
                cta_with_post_present.update_attributes(clone_params)
                cta_with_post_present.save
              end
            else
              # check item??
              begin
                cloned_cta = clone_and_create_cta(upload, clone_params, (upload.watermark rescue nil))
                # cloned_cta.build_user_upload_interaction(user_id: user_id, upload_id: upload.id)
                cloned_cta.aux = { "facebook_params" => change }
                cloned_cta.approved = true
                cloned_cta.save
              end
            end

          end

        end

      end

      render json: "OK"
    end
  end

  def get_facebook_clone_params(post, template_call_to_action)
    {
      "title" => "Titolo", 
      "description" => post["item"] == "share" ? "#{post["message"]}\n#{post["link"]}" : post["message"], 
      "upload" => (post["item"] == "photo" && post["link"]) ? open(post["link"]) : open(template_call_to_action.media_image.url), 
      "extra_fields" => {}
    }
  end

end