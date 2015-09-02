#!/bin/env ruby
# encoding: utf-8

class PasswordsController < Devise::PasswordsController

  def new
    super
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      flash[:alert] = "Ti è stata spedita un'email con le istruzioni per la configurazione della nuova password."
      redirect_to "/users/sign_in"
    else
      respond_with(resource)
    end
  end
end

