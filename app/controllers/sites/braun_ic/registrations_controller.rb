class Sites::BraunIc::RegistrationsController < RegistrationsController
  def create
    super
  end

  def after_sign_up_path_for(resource)
    "/"
  end
end