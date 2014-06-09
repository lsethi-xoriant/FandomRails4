  #!/bin/env ruby
# encoding: utf-8

class YoutubeWidgetController < ApplicationController

  def index
    @calltoactions = cache_short { calltoaction_active_with_tag("youtube", "ASC").to_a }
    @calltoactions_comingsoon = cache_short() { calltoaction_coming_soon_with_tag("youtube", "ASC").to_a }
  end

end
