class RssController < ApplicationController
  def rss
    @calltoactions = CallToAction.active.limit(10)
    respond_to do |format|
      format.rss { render :layout => false }
    end
  end

end
