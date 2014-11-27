#!/bin/env ruby
# encoding: utf-8

class Sites::Coin::SessionsController < SessionsController

  include CoinHelper

  def setUpAccount()
    assignPromocode()
    assignRegistrationReward()
  end

end

