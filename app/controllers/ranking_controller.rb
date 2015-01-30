#!/bin/env ruby
# encoding: utf-8

include PeriodicityHelper
include RankingHelper

class RankingController < ApplicationController
  
  def show_vote_rankings_page
    
  end
  
  def get_rank_page
    ranking = Ranking.find_by_name(params[:rank_name])
    result = get_full_rank(ranking, params[:page].to_i)
    respond_to do |format|
       format.json { render :json => result.to_json }
    end
  end
  
  def show_single_rank
    ranking = Ranking.find(params[:id])
    @rank_name = ranking.name
    render template: "/profile/ranking"
  end
  
end