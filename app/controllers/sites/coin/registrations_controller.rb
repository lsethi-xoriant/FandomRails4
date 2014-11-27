#!/bin/env ruby
# encoding: utf-8

class Sites::Coin::RegistrationsController < RegistrationsController

  include CoinHelper

  def setUpAccount()
    assignPromocode()
    assignRegistrationReward()
  end

end

