#!/bin/env ruby
# encoding: utf-8

include PeriodicityHelper

class RankingController < ApplicationController
  
  def show
    @ranking = Ranking.find(params[:id])
    period = get_period_by_kind(@ranking.period)
    if period
      @rank_list = UserReward.where("reward_id = ? and period_id = ?", @ranking.reward_id, period.id)
    else
      flash[:error] = "Spiacenti, non è ancora stata generata alcuna classifica per questo periodo"
    end
  end
  
end