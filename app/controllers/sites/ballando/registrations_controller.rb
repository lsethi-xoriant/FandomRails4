#!/bin/env ruby
# encoding: utf-8

class Sites::Ballando::RegistrationsController < RegistrationsController
  include FandomPlayAuthHelper

  def ballando_create
    user = User.new(params[:user])
    user.required_attrs = get_site_from_request(request)["required_attrs"]

    if user.valid?

      rai_user = build_rai_user(user)

      begin
        response = open("#{Rails.configuration.deploy_settings["sites"][request.site.id]["register_url"]}?#{rai_user.to_query}").read
        log_info("rai sign up response", { 'response' => response })
        strip_response = response.strip

        rai_response, pipe, md5 = strip_response.rpartition("|")

        # If user already exist in RAI and not in FANDOM, reponse not have md5
        if rai_response.empty?
          rai_response = md5
        end

        rai_response_json = JSON.parse(rai_response)
      rescue Exception => exception
        log_error("ballando registration error", { exception: exception.to_s }) 
        render template: "/devise/registrations/new", locals: { resource: user }
        return
      end

      if rai_response_json["authMyRaiTv"] == "OK"
        fandom_play_login(user)
        create
      else
        @error = rai_response_json["authMyRaiTv"] == "USERALREADYEXIST" ? "Username o email già utilizzati" : rai_response_json["authMyRaiTv"]
        render template: "/devise/registrations/new", locals: { resource: user }
      end

    else
      render template: "/devise/registrations/new", locals: { resource: user }
    end

  end

  def build_rai_user(user)
    rai_user = {
      "firstName" => user.first_name,
      "lastName" => user.last_name,
      "password" => user.password,
      "email" => user.email,
      "username" => user.username
    }
  end
  
  def on_success(user)
    fandom_play_login(user)
  end  

  protected 

  def after_sign_up_path_for(resource)
    #SystemMailer.welcome_mail(current_user).deliver
    "/refresh_top_window"
  end 

end

