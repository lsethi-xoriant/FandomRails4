class Sites::Disney::ProfileController < ProfileController
  include DisneyHelper
  
  skip_before_filter :check_user_logged, :only => :rankings
  
  def complete_registration

    user_params = params[:user]
    required_attrs = ["username", "username_length"]
    user_params = user_params.merge(required_attrs: required_attrs)

    response = {}
    current_user.assign_attributes(user_params)

    if !current_user.valid?
      response[:errors] = current_user.errors.full_messages
    else
      current_user.aux = { 
        "profile_completed" => true, 
      }.to_json
      if current_user.save
        response[:username] = current_user.username
        response[:avatar] = current_user.avatar_selected_url 
        log_audit("registration completion", { 'form_data' => params[:user], 'user_id' => current_user.id })
      else
        response[:errors] = current_user.errors.full_messages
      end
    end

    respond_to do |format|
      format.json { render json: response.to_json }
    end
  end
  
end