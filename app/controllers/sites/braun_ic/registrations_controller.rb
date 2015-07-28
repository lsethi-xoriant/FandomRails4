class Sites::BraunIc::RegistrationsController < RegistrationsController
  def create
    super
  end

  def after_sign_up_path_for(resource)
    "/"
  end

  def set_account_up
    create_user_interaction_for_registration()
    SystemMailer.welcome_mail_braun(current_user).deliver
  end
end