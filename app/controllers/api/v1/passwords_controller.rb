class Api::V1::PasswordsController < Devise::PasswordsController
  skip_before_filter :verify_authenticity_token

  respond_to :json
  
  def create
    # Solo le applicazioni correttamente registrate permettono la registrazione di un utente. In seguito alla registrazione
    # viene rilasciato un access_token.
    if params[:client_id] && params[:client_secret] && (app_id = Doorkeeper::Application.find_by_uid_and_secret(params[:client_id], params[:client_secret]))
      	debugger
      	resource = User.send_reset_password_instructions(resource_params)

	    if successfully_sent?(resource)
	      render :status => 200,
             :json => { success: true,
                        info: "sended",
                        data: { user: resource }}
	    else
	      render :status => :unprocessable_entity,
               :json => { :success => false,
                          info: "not sended",
                          data: { user: resource }}
	    end
    else
      render :status => :unprocessable_entity,
             :json => { :success => false,
                          :info => "invalid application",
                          :data => {} }
    end
  end

end
