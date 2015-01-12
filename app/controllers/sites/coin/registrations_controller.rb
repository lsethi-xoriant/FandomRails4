#!/bin/env ruby
# encoding: utf-8

class Sites::Coin::RegistrationsController < RegistrationsController

  include CoinHelper

  def create
    if !params[:user][:privacy].nil?
      params[:user][:privacy] = params[:user][:privacy] == "true"
    end

    if !params[:user][:newsletter].nil?
      params[:user][:newsletter] = params[:user][:newsletter] == "true"
    end

    super
  end

  def setUpAccount()
    assignRegistrationReward()
    #SystemMailer.welcome_mail(current_user).deliver
  end

end

