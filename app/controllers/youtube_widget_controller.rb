  #!/bin/env ruby
# encoding: utf-8

class YoutubeWidgetController < ApplicationController

  def index
    @calltoactions = cache_short("calltoactions_active_youtube") { calltoaction_active_with_tag("youtube", "ASC").to_a }
    @calltoactions_comingsoon = cache_short("calltoactions_comingsoon_youtube") { calltoaction_coming_soon_with_tag("youtube", "ASC").to_a }
  end

end
