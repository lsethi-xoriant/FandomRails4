class RssController < ApplicationController

  def calltoactions
    @calltoactions = CallToAction.active.limit(10).to_a

    respond_to do |format|
      format.rss { render layout: false }
    end
  end

end
