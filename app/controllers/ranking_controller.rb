#!/bin/env ruby
# encoding: utf-8

include PeriodicityHelper
include RankingHelper

class RankingController < ApplicationController
  
  def show_vote_rankings_page
    
  end
  
  def get_rank_page
    rank = JSON.parse(params[:rank])
    ranking = Ranking.find_by_name(rank['ranking']['name'])
    result = get_full_rank_page(ranking, params[:page])
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