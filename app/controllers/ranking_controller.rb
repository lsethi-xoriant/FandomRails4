#!/bin/env ruby
# encoding: utf-8

include PeriodicityHelper
include RankingHelper

class RankingController < ApplicationController
  
  def get_full_rank
    ranking = Ranking.find(params[:id])
    rank = get_ranking(ranking)
    rank_list = rank.rankings.slice(0,20)
    render_ranking(ranking.rank_type, ranking, rank_list, rank.rankings.count, rank.number_of_pages)
    #render_to_string "/ranking/_full_ranking", locals: { ranking: ranking, rank_list: rank_list, total: rank.total, number_of_pages: rank.number_of_pages }, layout: false, formats: :html
  end
  
  def get_fb_friends_rank
    current_user_fb_friends = current_user.facebook.get_connections("me", "friends").map { |f| f.id }
    ranking = Ranking.find(params[:id])
    rank = get_ranking(ranking)
    filtered_rank = rank.user_to_position.select { |key,_| current_user_fb_friends.include? key }
    filtered_rank = filtered_rank.sort_by { |key, value| value }
    rank_list = prepare_friends_rank_for_json(filtered_rank)
    render_ranking(ranking.rank_type, ranking, rank_list, rank.rankings.count, rank.number_of_pages)
    #render_to_string "/ranking/_full_ranking", locals: { ranking: ranking, rank_list: rank_list, total: rank.total, number_of_pages: rank.number_of_pages }, layout: false, formats: :html
  end
  
  def get_my_position_rank
    ranking = Ranking.find(params[:id])
    rank = get_ranking(ranking)
    my_position = rank.user_to_position[current_user.id]
    off = my_position - (20/2)
    rank_list = rank.rankings.slice(off,20)
    render_ranking(ranking.rank_type, ranking, rank_list, rank.rankings.count, rank.number_of_pages)
    #render_to_string "/ranking/_friends_ranking", locals: { ranking: ranking, rank_list: rank_list, total: rank.total, number_of_pages: rank.number_of_pages }, layout: false, formats: :html
  end
  
  def get_trirank(rank_list, ranking, my_position)
    ranks = {"first" => rank_list.first, "me" => rank_list[my_position], "last" => rank_list.last}
    render_to_string "/ranking/_trirank_ranking", locals: { rank_list: ranks, ranking: ranking }, layout: false, formats: :html
  end
  
  def render_ranking(rank_type, ranking, rank_list, total = 0, number_of_pages = 0)
    render_to_string "/ranking/_#{rank_type}_ranking", locals: { ranking: ranking, rank_list: rank_list, total: total, number_of_pages: number_of_pages }, layout: false, formats: :html
  end
  
  def get_full_rank_page
    page = prams[:page]
    off = (page-1)*20
    ranking = Ranking.find(params[:id])
    rank = get_ranking(ranking)
    rank_list = rank.rankings.slice(off,20)
    respond_to do |format|
      format.json { render json: rank_list.to_json }
    end
  end
  
end