#!/bin/env ruby
# encoding: utf-8

class Sites::Ballando::RegistrationsController < RegistrationsController
  include FandomPlayAuthHelper

  def ballando_create
    user = User.new(params[:user])

    if user.valid?

      rai_user = build_rai_user(user)

      begin
        rai_response_json = JSON.parse(open("#{Rails.configuration.deploy_settings["sites"][request.site.id]["register_url"]}?#{rai_user.to_query}").read)
      rescue Exception => exception
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

