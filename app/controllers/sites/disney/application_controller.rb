class Sites::Disney::ApplicationController < ApplicationController
  include RankingHelper
  
  def rankings
    rank = Ranking.find_by_name("#{$context_root}_general_chart")
    @property_rank = get_full_rank(rank)
    
    @fan_of_days = []
    (1..6).each do |i|
      day = Time.now - i.day
      @fan_of_days << {"day" => "#{day.strftime('%d %b.')}", "winner" => get_winner_of_day(day)}
    end
    
    render template: "profile/rankings"
  end
  
  def populate_rankings
    
  end
  
end