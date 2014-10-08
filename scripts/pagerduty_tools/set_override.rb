require_relative 'getpg'
require 'date'
require 'trollop'

def time_string(time_object)
  return time_object.iso8601.to_s
end

def query_dates
  # This shrinks the query to a one-day window
  since_date = time_string(Time.now)
  until_date = time_string((DateTime.now + 1))

  return {query_start: since_date, query_end: until_date}
end

def override_window(override_time)
  from_time = Time.now.iso8601.to_s
  # 3600 is number of seconds, change this to alter the override window
  until_time = (Time.now + override_time).iso8601.to_s

  return {override_start: from_time, override_end: until_time}
end

opts = Trollop::options do
  # Set help message
  banner("Usage: #{ __FILE__ } [options]")
  opt :email, 'Specify email address of override user', :type => :string,
    :required => true
  opt :schedule_name, 'Name of schedule to override', :type => :string,
    :default => 'Default', :short => '-n'
  opt :override_length, 'Number of seconds to maintain override for', :type => :int,
    :default => 3600, :short => '-t'
end

override_window_hash = override_window(opts[:override_length])

pg = TapJoy::PagerDuty.new
puts pg.set_override(**query_dates, **override_window_hash,
  user_id: pg.get_user_id(opts[:email]),
  schedule_id: pg.get_schedule_id(opts[:schedule_name]) # case-sensitive
)
