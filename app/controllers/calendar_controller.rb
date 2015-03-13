class CalendarController < ApplicationController

  def get_ical
    current_time = Time.now.utc.strftime("%Y%m%d")
    cal = build_ical(current_time, current_time, "summary", "description")
    render :text => cal.to_ical
  end

end
