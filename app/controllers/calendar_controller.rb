class CalendarController < ApplicationController

  def get_ical
    interaction = Interaction.find(params[:interaction_id])
    start_date = Time.parse(JSON.parse(interaction.resource.ical_fields)["start_datetime"]["value"])

    begin
      end_date = Time.parse(JSON.parse(interaction.resource.ical_fields)["end_datetime"]["value"])
    rescue Exception => exception
      end_date = ""
    end

    subtitle = (JSON.parse(interaction.call_to_action.extra_fields)["subtitle"] rescue "")

    cal = build_ical(start_date, end_date, interaction.call_to_action.title, subtitle)
    render :text => cal.to_ical
  end
  
  def get_calendar_events()
    events = get_ctas_with_tag("event")
  end
  
  def index
    
  end

end
