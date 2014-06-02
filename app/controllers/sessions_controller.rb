class SessionsController < Devise::SessionsController
  prepend_before_filter :anchor_provider_to_current_user, only: :create, :if => proc {|c| current_user && !env["omniauth.auth"].nil? }
  skip_before_filter :iur_authenticate

  def anchor_provider_to_current_user
    # Aggancio il provider all'utente corrente se loggato.
    current_user.logged_from_omniauth env["omniauth.auth"], params[:provider]
    flash[:notice] = "Agganciato #{ params[:provider] } all'utente"
    redirect_to "/"
  end

  def omniauth_failure
    flash[:error] = "Errore nella sincronizzazione con il provider, assicurati di avere accettato i permessi."
    redirect_to "/users/sign_up"
  end

   def create
    # Controllo se la creazione della sessione viene o meno da un provider per gli utenti.
    if env["omniauth.auth"].nil?
      if !(params['user'].blank?) && !(params['user']['password'].blank?)
        user = User.find_by_email(params['user']['email'])
        if user.nil? || !user.valid_password?(params['user']['password'])
          flash[:error] = "Dati non validi"
          redirect_to "/users/sign_up"
        else
          self.resource = warden.authenticate!(auth_options)
          set_flash_message(:notice, :signed_in) if is_navigational_format?
          sign_in(resource_name, resource)
       
          unless cookies[:connect_from_page].blank?
            connect_from_page = cookies[:connect_from_page]
            cookies.delete(:connect_from_page)
            redirect_to connect_from_page
          else
            redirect_to "/"
          end

        end
      else
        flash[:notice] = "Dati non validi"
        redirect_to "/users/sign_up"
      end
    else 
      user, from_registration = User.not_logged_from_omniauth env["omniauth.auth"], params[:provider]
      unless user.errors.any?
        sign_in(user)
        flash[:notice] = "from_registration" if from_registration

        if request.site.force_facebook_tab
          redirect_to request.site.force_facebook_tab
        else
          unless cookies[:connect_from_page].blank?
            connect_from_page = cookies[:connect_from_page]
            cookies.delete(:connect_from_page)
            redirect_to connect_from_page
          else
            redirect_to "/"
          end
        end

      else

        session["oauth"] ||= {}
        session["oauth"]["params"] = env["omniauth.auth"].except("extra") # Rimuovo extra per prevenire cookie overflow
        session["oauth"]["params"]["provider"] = params[:provider]
        render template: "/devise/registrations/new", :locals => { resource: user }   
      end # user.errors.any?
    end # env["omniauth.auth"].nil?
  end # create

end

