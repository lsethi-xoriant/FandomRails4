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
  
end
