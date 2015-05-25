module CalendarHelper
  
  def build_ical(dt_start, dt_end, summary, description, location)
    cal = Icalendar::Calendar.new
    cal.version = "2.0"
    cal.prodid = $site.id

    cal.event do |e|
      e.dtstart =  dt_start #Icalendar::Values::Date.new(dt_start)
      e.dtend = dt_end #Icalendar::Values::Date.new(dt_end)
      e.summary = summary
      e.description = description
      e.location = location
      e.ip_class = "PUBLIC"

      e.alarm do |a|
        a.action = "AUDIO"
        a.trigger = "-PT15M"
        a.append_attach "Basso"
      end

    end

    cal.publish
    cal

  end

  def get_ical_events(cta_ids)
    ical_events = []
    if cta_ids.any?
      Download.includes(:interaction => :call_to_action).where("interactions.call_to_action_id IN (?) AND interactions.when_show_interaction <> 'MAI_VISIBILE' AND downloads.ical_fields is not null", cta_ids).references(:interactions).each do |cal|
        ical_events << {
          cta: cal.interaction.call_to_action, 
          start_datetime: DateTime.parse(JSON.parse(cal.ical_fields)['start_datetime']['value']),
          end_datetime: DateTime.parse(JSON.parse(cal.ical_fields)['end_datetime']['value']),
          ical_id: cal.interaction.id,
          slug: cal.interaction.call_to_action.slug
        }
      end
    end
    ical_events
  end
  
end
