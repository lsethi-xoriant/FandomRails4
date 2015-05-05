class Easyadmin::PromocodeController < Easyadmin::EasyadminController
  include EasyadminHelper
  include DateMethods

  layout "admin"

  def index_promocode
    authorize! :manage, :promocodes
  end

  def new_promocode
    authorize! :manage, :promocodes

    @inter_promocode = Interaction.new(name: "#PRCODE#{ DateTime.now.strftime('%FT%T') }")
    @inter_promocode.resource = Promocode.new
  end

  def create_promocode
    authorize! :manage, :promocodes

    @inter_promocode = Interaction.create(params[:interaction])
    if @inter_promocode.errors.any?
      render template: "/easyadmin/easyadmin/new_promocode"     
    else
      flash[:notice] = "Promocode generato correttamente"
      redirect_to "/easyadmin/promocode"
    end
  end

end