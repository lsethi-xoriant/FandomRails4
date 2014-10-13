#!/bin/env ruby
# encoding: utf-8

class Sites::Ballando::SessionsController < SessionsController
  include FandomPlayAuthHelper
  
  def ballando_create
    begin

      rai_response = open("#{Rails.configuration.deploy_settings["sites"][request.site.id]["register_url"]}/loginSocialBallando.do?#{params[:user].to_query}").read     
      log_info("rai sign in response", { 'response' => rai_response })
      
      rai_strip_response = rai_response.strip

      valid_response, rai_response_user = evaluate_response(rai_strip_response)

      if valid_response

        rai_response_user = JSON.parse(rai_response_user)

        if rai_response_user.empty?
          flash[:error] = "Username o password errati"
          redirect_to "/users/sign_in" and return
        end

        if rai_response_user["authMyRaiTv"] == "OK"
          user = User.find(:first, conditions: ["lower(username) = ?", rai_response_user["UID"].downcase])

          unless user
            password = Devise.friendly_token.first(8)
            user = User.create(
                username: rai_response_user["UID"], 
                email: "#{rai_response_user["UID"]}@FAKE___DOMAIN.com", 
                first_name: rai_response_user["firstName"], 
                last_name: rai_response_user["lastName"],
                privacy: true,
                password: password,
                required_attrs: get_site_from_request(request)["required_attrs"]
                )  

            if user.errors.any?
              flash[:error] = user.errors.full_messages.map { |error_message| "#{error_message}<br>"}.join("").html_safe
              redirect_to "/users/sign_in"
              return
            end

          end

          sign_in(:user, user)
          on_success(user)
          redirect_to "/refresh_top_window"
          
        else
          flash[:error] = "Username o password errati"
          redirect_to "/users/sign_in"
        end

      else
        render template: "/devise/sessions/new", locals: { resource: User.new }
      end

    rescue Exception => exception
      redirect_to "/users/sign_in"
    end
  end

  def ballando_create_from_provider
    response = Hash.new

    rai_response = params["user"]

    log_info("rai sign in from provider response", { 'response' => rai_response })

    valid_response, rai_response_user = evaluate_response(rai_response.strip)
    rai_response_user = JSON.parse(rai_response_user)

    if valid_response && rai_response_user["authMyRaiTv"] == "OK"

      if rai_response_user.key?("user") && !rai_response_user["user"]["email"].empty? #rai_response_user["user"].key?("email") 
        user_email = rai_response_user["user"]["email"]
      else
        user_email = "#{rai_response_user["UID"]}@FAKE___DOMAIN.com"
      end
      
      user = User.find_by_username(rai_response_user["UID"])
      unless user
        user = User.find_by_email(user_email)
        if user
          user.username = rai_response_user["UID"]
        end
      end

      if user && user.email.include?("@FAKE___DOMAIN.com")
        user.update_attributes(:email => user_email, :avatar_selected_url => rai_response_user["user"]["thumbnailURL"])
      elsif user.nil?
        user = new_user_from_provider(rai_response_user, user_email)
      end

      authentication = user.authentications.find_by_provider(rai_response_user["user"]["loginProvider"])

      if authentication
        authentication.update_attributes(authentication_attributes_from_provider(rai_response_user))
      else
        user.authentications.build(authentication_attributes_from_provider(rai_response_user))
      end

      if user.errors.blank?
        response[:connect_from_page] = path_for_redirect_after_successful_login()
        sign_in(:user, user)
        on_success(user)
      else
        response[:errors] = user.errors.full_messages.map { |error_message| "#{error_message}<br>"}
      end

    else
      response[:errors] = rai_response_user["authMyRaiTv"]
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end

  def path_for_redirect_after_successful_login
    if cookies[:connect_from_page].blank?
      "/"
    else
      connect_from_page = cookies[:connect_from_page]
      cookies.delete(:connect_from_page)
      connect_from_page
    end
  end

  def evaluate_response(response)
    response_user, pipe, md5 = response.rpartition("|")    
    md5_calculated = Digest::MD5.hexdigest("#{response.gsub(md5, "ballando")}")
    valid_response = md5 == md5_calculated
    [valid_response, response_user]
  end

  def on_success(user)
    fandom_play_login(user)
  end  

  def authentication_attributes_from_provider(response_user)
    {
      uid: response_user["UID"],
      provider: response_user["user"]["loginProvider"],
      avatar: response_user["user"]["thumbnailURL"],
      aux: response_user.to_json
    }
  end

  def new_user_from_provider(response_user, user_email)
    password = Devise.friendly_token.first(8)
    
    provider = response_user["user"]["loginProvider"]

    User.create(
      username: response_user["UID"], 
      email: user_email, 
      first_name: response_user["user"]["firstName"], 
      last_name: response_user["user"]["lastName"],
      avatar_selected: provider,
      avatar_selected_url: response_user["user"]["thumbnailURL"],
      privacy: true,
      password: password,
      required_attrs: get_site_from_request(request)["required_attrs"]
    )
  end

  def ballando_destroy
    destroy
  end

  def after_sign_out_path_for(resource_or_scope)
    Rails.configuration.deploy_settings["sites"]["ballando"]["stream_url"]
  end

end