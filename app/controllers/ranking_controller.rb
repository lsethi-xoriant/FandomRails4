#!/bin/env ruby
# encoding: utf-8

include PeriodicityHelper
include RankingHelper

class RankingController < ApplicationController
  
  def get_full_rank(ranking)
    rank = get_ranking(ranking)
    my_position = rank.user_to_position[current_user.id]
    compose_ranking_info(ranking.rank_type, ranking, rank.rank_list, my_position, rank.rankings.count, rank.number_of_pages)
  end
  
  def get_fb_friends_rank(ranking)
    current_user_fb_friends = current_user.facebook.get_connections("me", "friends").map { |f| f.id }
    rank = get_ranking(ranking)
    filtered_rank = rank.user_to_position.select { |key,_| current_user_fb_friends.include? key }
    filtered_rank = filtered_rank.sort_by { |key, value| value }
    rank_list = prepare_friends_rank_for_json(filtered_rank)
    my_position = get_position_among_friends(rank_list)
    compose_ranking_info(ranking.rank_type, ranking, rank_list, my_position, rank.rankings.count, rank.number_of_pages)
  end
  
  def compose_ranking_info(rank_type, ranking, rank_list, total = 0, number_of_pages = 0)
    if rank_type == "my_position"
      current_page = get_page_from_position(my_position, RANKING_USER_PER_PAGE) 
      off = (current_page - 1) * RANKING_USER_PER_PAGE
    else
      current_page = 1
      off = 0
    end
    rank_list = rank.rankings.slice(off, RANKING_USER_PER_PAGE)
    {rank_list: rank_list, rank_type: rank_type, ranking: ranking, current_page: current_page, total: total, number_of_pages: number_of_pages}
  end
  
  def get_full_rank_page
    page = prams[:page]
    off = (page - 1) * RANKING_USER_PER_PAGE
    ranking = Ranking.find(params[:id])
    rank = get_ranking(ranking)
    rank_list = rank.rankings.slice(off, RANKING_USER_PER_PAGE)
    respond_to do |format|
      format.json { render json: rank_list.to_json }
    end
  end
  
  def show_rankings_page
    @rankings = Array.new
    Ranking.each do |r|
      if r.people_filter != "all"
        @rankings << send("get_#{r.people_filter}_rank", r)
      else
        @rankings << get_full_rank(r)
      end
    end
  end
  
end