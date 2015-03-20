class CalendarController < ApplicationController

  def get_ical
    start_date = params[:params][:start_date]
    end_date = params[:params][:end_date]
    cal = build_ical(start_date, end_date, params[:params][:summary], params[:params][:description])
    render :text => cal.to_ical
  end
  
  def get_calendar_events()
    events = get_ctas_with_tag("event")
  end
  
  def index
    
  end

end
