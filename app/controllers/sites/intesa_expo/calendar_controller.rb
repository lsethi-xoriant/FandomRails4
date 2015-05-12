class Sites::IntesaExpo::CalendarController < CalendarController
  include IntesaExpoHelper
  
  class Calendar
    
    attr_accessor :events
    attr_accessor :today
    attr_accessor :today_events
    
    def initialize(events, current_day)
      @events = events
      @today = current_day
      @today_events = events[current_day.day]
    end
    
  end
  
  def index
    
    monthes_map = {
      "gennaio" => "01-01-2015",
      "febbraio" => "01-02-2015",
      "marzo" => "01-03-2015",
      "aprile" => "01-04-2015",
      "maggio" => "01-05-2015",
      "giugno" => "01-06-2015",
      "luglio" => "01-07-2015",
      "agosto" => "01-08-2015",
      "settembre" => "01-09-2015",
      "ottobre" => "01-10-2015",
      "novembre" => "01-11-2015",
      "dicembre" => "01-12-2015",
      "jenuary" => "01-01-2015",
      "february" => "01-02-2015",
      "march" => "01-03-2015",
      "april" => "01-04-2015",
      "may" => "01-05-2015",
      "june" => "01-06-2015",
      "july" => "01-07-2015",
      "august" => "01-08-2015",
      "september" => "01-09-2015",
      "october" => "01-10-2015",
      "november" => "01-11-2015",
      "december" => "01-12-2015"
    }
    
    today = DateTime.now.utc
    if params[:day]
      if monthes_map.has_key?(params[:day])
        today = DateTime.parse(monthes_map[params[:day]]).utc
        @day_selected = monthes_map[params[:day]]
      else
        today = DateTime.parse(params[:day]).utc
        @day_selected = params[:day]
      end
    end
    
    month_calendar = initialize_calendar(today)
    @aux_other_params = {
      calendar_stripe: {
        name: "AgendaGiornaliera",
        title: "AgendaGiornaliera",
        slug: "AgendaGiornaliera"
      },
      today_events: month_calendar.today_events.nil? ? nil : month_calendar.today_events.sort_by { |event| event.start },
      tag_menu_item: "calendar"
    }
    
    @today = month_calendar.today
    
    if get_intesa_property == "imprese"
      @aux_other_params = {
        "expo_events" => get_intesa_expo_ctas_with_tag("event"),
        "gallery_events" => get_intesa_expo_ctas_with_tag("gallery"),
        "tag_menu_item" => "calendar"
      }
    end

  end
  
  def initialize_calendar(today)
    cal_events = init_calendar_events(today)
    day_of_month = today.day
    Calendar.new(cal_events, today)
  end
  
  def init_calendar_events(today)
    month_key = "#{get_intesa_property}_#{today.month}_#{today.year}"
    cal_events = cache_medium(get_month_calendar_cache_key(month_key)) do
      events = get_calendar_events(today.beginning_of_month, today.end_of_month)
      cal_events = []
      
      events.each do |event|
        if event.ical_id
          event.id = event.ical_id
          (cal_events[DateTime.parse(event.start).day] ||= []) << event
        end
      end
      cal_events
    end
    cal_events
  end
  
  def get_calendar_events(start_date, end_date)
    language_tag = get_tag_from_params(get_intesa_property)
    event_tag = Tag.find_by_name("event-#{get_intesa_property}")
    params = {
      ical_start_datetime: start_date.strftime("%Y-%m-%d %H:%M:%S %z"),
      ical_end_datetime: end_date.strftime("%Y-%m-%d %H:%M:%S %z"),
      order_string: "cast(\"ical_fields\"->'start_datetime'->>'value' AS timestamp) ASC",
      limit: {
        offset: 0,
        perpage: 10000
      }
    }

    tags = [event_tag] + [language_tag]
    events, has_more = get_content_previews_with_tags(tags, params)
    events
  end
  
  def prepare_events_for_calendar(events)
    calendar_events = []
    events.each do |days_events|
      if !days_events.nil?
        days_events.each do |event|
          calendar_events << event
        end
      end
    end
    calendar_events.to_json
  end
  
  def fetch_events
    start_date = DateTime.parse("01-#{params[:month]}-#{params[:year]}").utc
    month_calendar = initialize_calendar(start_date)
    respond_to do |format|
      format.json { render :json => prepare_events_for_calendar(month_calendar.events) }
    end
  end
  
  def find_next_event_day(starting_day, events)
    result = nil
    if starting_day < events.count-1
      starting_day.upto(events.count-1).each do |day|
        if events[day].present?
          result = day
          break
        end
      end
    end
    result
  end
  
  def find_prev_event_day(starting_day, events)
    result = nil
    if starting_day > 1
      starting_day.downto(1).each do |day|
        if events[day].present?
          result = day
          break
        end
      end
    end
    result
  end
  
  def find_first_event_in_month(events)
    result = nil
    1.upto(events.count-1) do |day|
      if events[day].present?
        result = day
        break
      end
    end
    result
  end
  
  def find_last_event_in_month(events)
    result = nil
    (events.count-1).downto(1) do |day|
      if events[day].present?
        result = day
        break
      end
    end
    result
  end
  
  def find_nearest_day_with_event(today, events)
    request_day = today.day.to_i
    if params[:dir]
      if params[:dir] == 'next'
        find_next_event_day(request_day, events) || find_first_event_in_month(events) || 1
      else
        find_prev_event_day(request_day, events) || find_last_event_in_month(events) || 1
      end
    else
      find_next_event_day(request_day, events) || find_prev_event_day(request_day, events) || 1
    end    
  end
  
end