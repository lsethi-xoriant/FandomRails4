class Easyadmin::HomeLaunchersController < Easyadmin::EasyadminController
  include EasyadminHelper

  layout "admin"

  before_filter :authorize_user

  def authorize_user
    authorize! :manage, :carousel
  end

  def index
    @home_launchers = HomeLauncher.all
  end

  def new
    @home_launcher = HomeLauncher.new
  end

  def edit
    @home_launcher = HomeLauncher.find(params[:id])
  end

  def create
    @home_launcher = HomeLauncher.create(params[:home_launcher])
    if @home_launcher.errors.any?
      render template: "/easyadmin/home_launchers/new"     
    else
      flash[:notice] = "Item generato correttamente"
      redirect_to "/easyadmin/home_launchers"
    end
  end

  def update
    @home_launcher = HomeLauncher.find(params[:id])
    unless @home_launcher.update_attributes(params[:home_launcher])
      render "edit"   
    else
      flash[:notice] = "Item aggiornato correttamente"
      redirect_to "/easyadmin/home_launchers"
    end
  end

end