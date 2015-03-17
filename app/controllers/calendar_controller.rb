class CalendarController < ApplicationController

  def get_ical
    start_date = Time.now.utc.strftime("%Y%m%d")
    end_date = start_date
    cal = build_ical(start_date, end_date, "summary", "description")
    render :text => cal.to_ical
  end

end
