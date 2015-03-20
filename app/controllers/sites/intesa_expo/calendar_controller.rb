class Sites::IntesaExpo::CalendarController < CalendarController
  include IntesaExpoHelper
  
  def index
    
    @today = DateTime.now.utc
    if params[:day]
      @today = DateTime.parse(params[:day]).utc
    end
    start_time = @today.beginning_of_day
    end_time = @today.end_of_day
    month_start = @today.beginning_of_month
    month_end = @today.end_of_month
    @aux_other_params = {
      today_events: prepare_contents(get_calendar_events(start_time, end_time))
    }
    @calendar_events = prepare_events_for_calendar(get_calendar_events(month_start, month_end))
    
  end
  
  def get_calendar_events(start_date, end_date)
    language_tag_id = get_tag_from_params($context_root || "it").id
    event_tad_id = Tag.find_by_name("event").id
    get_intesa_expo_event_ctas_in_period([language_tag_id, event_tad_id], start_date, end_date)
  end
  
  def prepare_events_for_calendar(ctas)
    events = []
    ctas.each do |cta|
      events << {
        "title" => cta.title,
        "description" => cta.description,
        "image" => cta.thumbnail.url(:thumb),
        "start" => cta.valid_from,
        "end" => cta.valid_to
      }
    end
    events.to_json
  end
  
  def get_calendar_events_json
    start_date = DateTime.parse(params[:start_time]).utc
    end_date = DateTime.parse(params[:end_time]).utc
    respond_to do |format|
      format.json { render :json => prepare_events_for_calendar(get_calendar_events(start_date, end_date)) }
    end
  end
  
end