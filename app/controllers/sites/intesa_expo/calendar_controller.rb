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
    
    today = DateTime.now.utc
    if params[:day]
      today = DateTime.parse(params[:day]).utc
    end
    
    month_calendar = initialize_calendar(today)
    
    @aux_other_params = {
      today_events: month_calendar.today_events
    }
    
    @today = month_calendar.today
    
    if get_intesa_property == "imprese"
      @aux_other_params = {
        "expo_events" => get_intesa_expo_ctas_with_tag("event-imprese"),
        "gallery_events" => get_intesa_expo_ctas_with_tag("gallery-imprese")
      }
    end
    
  end
  
  def initialize_calendar(today)
    cal_events = init_calendar_events(today)
    day_of_month = today.day
    if cal_events[today.day].nil?
      day_of_month = find_nearest_day_with_event(today, cal_events)
    end
    Calendar.new(cal_events, DateTime.parse("#{day_of_month}-#{today.month}-#{today.year}"))
  end
  
  def init_calendar_events(today)
    month_key = "#{get_intesa_property}_#{today.month}_#{today.year}"
    cal_events = cache_medium(get_month_calendar_cache_key(month_key)) do
      events = get_calendar_events(today.beginning_of_month, today.end_of_month)
      cal_events = []
      events.each do |event|
        if cal_events[event.valid_from.day].nil?
          cal_events[event.valid_from.day] = Array.new
        end
        cal_events[event.valid_from.day] << cta_to_content_preview(event)
      end
      cal_events
    end
    cal_events
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
  
  def get_calendar_events(start_date, end_date)
    language_tag_id = get_tag_from_params(get_intesa_property).id
    event_tag_id = Tag.find_by_name("event-#{get_intesa_property}").id
    get_intesa_expo_event_ctas_in_period([language_tag_id, event_tag_id], start_date, end_date)
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
    start_date = DateTime.parse(params[:start]).utc + 1.month
    month_calendar = initialize_calendar(start_date)
    respond_to do |format|
      format.json { render :json => prepare_events_for_calendar(month_calendar.events) }
    end
  end
  
end