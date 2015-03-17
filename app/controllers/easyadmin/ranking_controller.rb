class Easyadmin::RankingController < Easyadmin::EasyadminController
  include EasyadminHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :manage, :rankings
  end

  def index
    @rankings = Ranking.all
  end

  def new
    @ranking = Ranking.new
    @reward_options = Reward.where("countable = TRUE").map { |r| [r.name, r.id] }
  end
  
  def create
    @ranking = Ranking.create(params[:ranking])
    if @ranking.errors.any?
      render template: "edit"
    else
      flash[:notice] = "Classifica inserita correttamente"
      redirect_to "/easyadmin/ranking"
    end
  end
  
  def update
    @ranking = Ranking.find(params[:id])
    @ranking.update_attributes(params[:ranking])
    if @ranking.errors.any?
      render template: "edit"
    else
      flash[:notice] = "Classifica aggiornata correttamente"
      redirect_to "/easyadmin/ranking"
    end
  end

  def edit
    @ranking = Ranking.find(params[:id])
    @reward_options = Reward.where("countable = TRUE").map { |r| [r.name, r.id] }
  end
  
  def show
    @tag = Tag.find(params[:id])
  end
  
end