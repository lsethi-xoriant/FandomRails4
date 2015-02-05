class Easyadmin::VoteRankingController < Easyadmin::EasyadminController
  include EasyadminHelper
  include GraphHelper

  layout "admin"

  def index
    @vote_rankings = VoteRanking.all
  end

  def new
    @vote_ranking = VoteRanking.new
  end
  
  def create 
    @vote_ranking = VoteRanking.create(params[:vote_ranking])
    tag_list = params[:tag_list].split(",")
    if @vote_ranking.errors.any?
      @tag_list = tag_list
      render template: "edit"     
    else
      update_and_redirect(tag_list, "Classifica voti inerita correttamente", @vote_ranking)
    end
  end
  
  def update_and_redirect(tag_list, flash_message, vote_ranking)
    update_ranking_tag(tag_list,vote_ranking)
    flash[:notice] = flash_message
    redirect_to "/easyadmin/vote_ranking"
  end
  
  def update_ranking_tag(tag_list, vote_ranking)
    vote_ranking.vote_ranking_tags.destroy_all
    tag_list.each do |t|
      tag = Tag.find_by_name(t)
      tag = Tag.create(name: t) unless tag
      VoteRankingTag.create(tag_id: tag.id, vote_ranking_id: vote_ranking.id)
    end
  end
  
  def update
    @vote_ranking = VoteRanking.find(params[:id])
    tag_list = params[:tag_list].split(",")
    @vote_ranking.update_attributes(params[:vote_ranking])
    if @vote_ranking.errors.any?
      @tag_list = tag_list
      render template: "edit"
    else
      update_and_redirect(tag_list, "Classifica voti aggiornata correttamente", @vote_ranking)
    end
  end

  def edit
    @vote_ranking = VoteRanking.find(params[:id])
    @tag_list_arr = Array.new
    @vote_ranking.vote_ranking_tags.each { |t| @tag_list_arr << t.tag.name }
    @tag_list = @tag_list_arr.join(",")
  end
    
  def show
    @vote_ranking = VoteRanking.find(params[:id])
  end
    
end