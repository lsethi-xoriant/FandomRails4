class Sites::Ballando::RegistrationsController < RegistrationsController
  def ballando_create
    user = User.new(params[:user])
    if user.valid?

      rai_user = build_rai_user(user)

      begin
        rai_response_json = JSON.parse(open("#{Rails.configuration.deploy_settings["sites"][request.site.id]["register_url"]}?#{rai_user.to_query}").read)
      rescue Exception => exception
        user.errors.add("Eccezione", exception)
        render template: "/devise/registrations/new", locals: { resource: user }
        return
      end

      if rai_response_json["authMyRaiTv"] == "OK"
        create
      else
        user.errors.add("Utente", rai_response_json["authMyRaiTv"]) 
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
end

