class Easyadmin::CacheController < Easyadmin::EasyadminController
  include EasyadminHelper

  layout "admin"

  def clear_cache
    Rails.cache.clear
    flash[:notice] = "Cache cancellata!"
  end

end