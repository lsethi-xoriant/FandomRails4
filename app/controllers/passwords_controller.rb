
class PasswordsController < Devise::PasswordsController

  def new
    super
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      redirect_to "/"
    else
      respond_with(resource)
    end
  end

end

