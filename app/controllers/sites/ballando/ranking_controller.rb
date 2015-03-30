
class Sites::Ballando::RankingController < RankingController
  
  include BallandoHelper
  
  def get_rank_page
    ranking = Ranking.find_by_name(params[:rank_name])
    result = ballando_get_full_rank_page(ranking, params[:page].to_i)
    respond_to do |format|
       format.json { render :json => result.to_json }
    end
  end

end