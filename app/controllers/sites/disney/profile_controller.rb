class Sites::Disney::ProfileController < ProfileController
  include DisneyHelper
  
  def get_current_property
    get_disney_property
  end
  
  def rankings
    rank = Ranking.find_by_name("#{get_current_property}_general_chart")
    @property_rank = get_full_rank(rank)
    
    @fan_of_days = []
    (1..6).each do |i|
      day = Time.now - i.day
      @fan_of_days << {"day" => "#{day.strftime('%d %b.')}", "winner" => get_winner_of_day(day)}
    end
    
    render template: "profile/rankings"
  end
  
end