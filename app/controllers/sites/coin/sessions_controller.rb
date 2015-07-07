#!/bin/env ruby
# encoding: utf-8

class Sites::Coin::SessionsController < SessionsController

  include CoinHelper

  def set_account_up()
    assignRegistrationReward()
    #SystemMailer.welcome_mail(current_user).deliver
  end

end

