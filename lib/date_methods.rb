module DateMethods

  def time_parsed_to_utc(datetime)
    Time.parse("#{datetime} #{USER_TIME_ZONE}").utc
  end

  def datetime_parsed_to_utc(datetime)
    DateTime.parse("#{datetime}").utc
  end

end