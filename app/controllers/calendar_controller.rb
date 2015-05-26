class CalendarController < ApplicationController

  def get_ical
    interaction = Interaction.find(params[:interaction_id])
    ical_fields = interaction.resource.ical_fields 
    start_date = Time.parse(ical_fields["start_datetime"]["value"])

    begin
      end_date = Time.parse(ical_fields["end_datetime"]["value"])
    rescue Exception => exception
      end_date = ""
    end

    subtitle = interaction.call_to_action.extra_fields["subtitle"]
    cal = build_ical(start_date, end_date, interaction.call_to_action.title, subtitle, ical_fields["location"])
    render :text => cal.to_ical
  end
  
  def get_calendar_events()
    events = get_ctas_with_tag("event")
  end
  
  def index
    
  end

end
