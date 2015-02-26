class Easyadmin::CacheController < Easyadmin::EasyadminController
  include EasyadminHelper

  layout "admin"

  def clear_cache
    dalli_client = Dalli::Client.new
    dalli_client.flush
    flash[:notice] = "Cache cancellata!"
  end

end