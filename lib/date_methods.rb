module DateMethods

  def parse_to_utc(datetime)
    Time.parse("#{datetime} #{USER_TIME_ZONE}").utc
  end

end