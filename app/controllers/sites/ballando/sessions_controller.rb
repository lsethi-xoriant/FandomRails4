class Sites::Ballando::SessionsController < SessionsController
  include FandomPlayAuthHelper
  
  def ballando_create
    begin

      rai_response = (open("#{Rails.configuration.deploy_settings["sites"][request.site.id]["register_url"]}/loginSocialBallando.do?#{params[:user].to_query}").read).strip
      rai_response_user, pipe, rai_md5 = rai_response.rpartition("|")    
      rai_md5_calculated = Digest::MD5.hexdigest("#{rai_response.gsub(rai_md5, "ballando")}")

      if rai_md5 == rai_md5_calculated
        rai_response_user = JSON.parse(rai_response_user)

        if rai_response_user["authMyRaiTv"] == "OK"
          user = User.find_by_username(rai_response_user["UID"])
          unless user
            password = Devise.friendly_token.first(8)
            user = User.create(
                username: rai_response_user["UID"], 
                email: "#{rai_response_user["UID"]}@FAKE___DOMAIN.com", 
                first_name: rai_response_user["firstName"], 
                last_name: rai_response_user["lastName"],
                password: password
                )
          end

          sign_in(:user, user)
          on_success(user)
          redirect_after_successful_login
        else
          flash[:error] = rai_response_user["authMyRaiTv"]
          redirect_to "/user/sign_up"
        end

      else
        render template: "/devise/registrations/new", locals: { resource: User.new }
      end

    rescue Exception => exception
      User.new.errors.add("Eccezione", exception)
      render template: "/devise/registrations/new", locals: { resource: User.new }
      return
    end
  end
  
  def on_success(user)
    fandom_play_login(user)
  end
end