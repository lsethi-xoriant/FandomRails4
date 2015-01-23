class Sites::Disney::RssController < ApplicationController
  include DisneyHelper

  def calltoactions
    @property = get_tag_from_params(get_disney_property())
    @calltoactions = cache_short(get_rss_ctas_in_property_cache_key(@property.id)) do
      get_disney_ctas(@property).limit(10).to_a
    end
    respond_to do |format|
      format.rss { render layout: false, template: "/rss/calltoactions" }
    end
  end

end