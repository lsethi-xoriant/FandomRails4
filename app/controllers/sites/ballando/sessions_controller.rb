class Sites::Ballando::SessionsController < SessionsController
  include FandomPlayAuthHelper
  
  def ballando_create
    begin

      rai_response = (open("#{Rails.configuration.deploy_settings["sites"][request.site.id]["register_url"]}/loginSocialBallando.do?#{params[:user].to_query}").read).strip
      valid_response, rai_response_user = evaluate_response(rai_response)

      if valid_response
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
    end
  end

  def ballando_create_from_provider
    response = Hash.new

    rai_response = params["user"]
    valid_response, rai_response_user = evaluate_response(rai_response.strip)
    rai_response_user = JSON.parse(rai_response_user)

    if valid_response && rai_response_user["authMyRaiTv"] == "OK"
      
      unless rai_response_user["profile"]["email"] && (user = User.find_by_email(rai_response_user["profile"]["email"])) 
        user = new_user_from_provider(rai_response_user)
      end

      authentication = user.authentications.find_by_provider(rai_response_user["loginProvider"])

      if authentication
        authentication.update_attributes(authentication_attributes_from_provider(rai_response_user))
      else
        user.authentications.build(authentication_attributes_from_provider(rai_response_user))
      end

      response[:user] = user

      if user.errors.blank?
        sign_in(:user, user)
        on_success(user)
      end

    end

    respond_to do |format|
      format.json { render json: response.to_json }
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
      provider: response_user["loginProvider"],
      avatar: response_user["profile"]["photoURL"],
      aux: response_user.to_json
    }
  end

  def new_user_from_provider(response_user)
    password = Devise.friendly_token.first(8)

    if response_user["profile"]["email"]
      user_email = response_user["profile"]["email"]
    else
      user_email = "#{response_user["UID"]}@FAKE___DOMAIN.com"
    end

    User.create(
      username: response_user["UID"], 
      email: user_email, 
      first_name: response_user["profile"]["firstName"], 
      last_name: response_user["profile"]["lastName"],
      password: password
    )
  end

end