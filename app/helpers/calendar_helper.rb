module CalendarHelper
  
  def build_ical(dt_start, dt_end, summary, description)
    cal = Icalendar::Calendar.new
    cal.version = "1.0"
    cal.prodid = $site.id
    cal.event do |e|
      e.dtstart = Icalendar::Values::Date.new(dt_start)
      e.dtend = Icalendar::Values::Date.new(dt_end)
      e.summary = summary
      e.description = description
      e.ip_class = "PUBLIC"
    end
    cal.publish
    cal
  end
  
end
