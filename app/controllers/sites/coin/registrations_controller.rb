#!/bin/env ruby
# encoding: utf-8

class Sites::Coin::RegistrationsController < RegistrationsController

  include CoinHelper

  def create
    params[:user][:privacy] = params[:user][:privacy] == "true"
    params[:user][:newsletter] = params[:user][:newsletter] == "true"
    super
  end

  def setUpAccount()
    assignPromocode()
    assignRegistrationReward()
  end

end

