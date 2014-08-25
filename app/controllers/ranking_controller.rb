#!/bin/env ruby
# encoding: utf-8

include PeriodicityHelper
include RankingHelper

class RankingController < ApplicationController
  
  def show
    @ranking = Ranking.find(params[:id])
    rank = get_ranking(@ranking)
    @rank_list = rank.rankings.slice(0,20)
    if current_user
      user_position = rank.user_to_position[current_user.id]
      if user_position < 20
        @user_rankings = @rank_list
      else
        start_position = user_position - (20/2)
        @user_rankings = rank.rankings.slice(start_position,20)
      end
    end 
  end
  
end