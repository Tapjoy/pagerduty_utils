require 'pagerduty/base'
require 'date'

module TapJoy
  module PagerDuty; end
end

class TapJoy::PagerDuty::Override

  # Initializer services to import values from pg_connect.yaml
  # to configure organization-specific values (currently, subdomain and api_token)
  def initialize(email, schedule_name, override_length)
    pg = TapJoy::PagerDuty::Base.new
    override_window_hash = override_window(override_length)
    puts pg.set_override(**query_dates, **override_window_hash,
      user_id: pg.get_user_id(email),
      schedule_id: pg.get_schedule_id(schedule_name) # case-sensitive
    )
  end

  private
  def time_string(time_object)
    return time_object.iso8601.to_s
  end

  def query_dates
    # This shrinks the query to a one-day window
    since_date = time_string(Time.now)
    until_date = time_string((Time.now + (1*86400)))

    return {query_start: since_date, query_end: until_date}
  end

  def override_window(override_time)
    from_time = Time.now.iso8601.to_s
    # 3600 is number of seconds, change this to alter the override window
    until_time = (Time.now + override_time).iso8601.to_s

    return {override_start: from_time, override_end: until_time}
  end
end
