require 'httparty'
require 'json'
require 'yaml'

module TapJoy; end
class TapJoy::PagerDuty

  # Initializer services to import values from pg_connect.yaml
  # to configure organization-specific values (currently, subdomain and api_token)
  def initialize
    pg_conn = YAML.load_file('pg_connect.yaml')
    @AUTH_HEADER = {
      :subdomain    => pg_conn[:subdomain],
      :token_string => "Token token=#{pg_conn[:api_token]}"
    }
  end

  # Given an email address return the user_id that pagerduty uses for lookups
  def get_user_id(email)
    endpoint = "https://#{@AUTH_HEADER[:subdomain]}.pagerduty.com/api/v1/users"
    out_array = get_object(endpoint)['users'].select { |i| i['email'].eql?(email) }
    return Hash[*out_array]['id']
  end

  # Given the name of a schedule return the schedule_id that pagerduty uses for lookups
  def get_schedule_id(schedule_name)
    endpoint = "https://#{@AUTH_HEADER[:subdomain]}.pagerduty.com/api/v1/schedules/"
    out_array = get_object(endpoint)['schedules'].select { |i| i['name'].eql?(schedule_name)}
    return Hash[*out_array]['id']
  end

  # The set_override method takes in several variables and returns
  # the REST response upon (attempting) completion of an override action
  def set_override(query_start:, query_end:, override_start:, override_end:,
    user_id:, schedule_id:)
    # Ruby 2.x style kw-args is required here to make hash passing easier

    endpoint = "https://#{@AUTH_HEADER[:subdomain]}.pagerduty.com/api/v1/schedules/" \
      "#{schedule_id}/overrides?since=#{query_start}&until=#{query_end}"

    data = {
      override: {
        user_id: user_id,
        start: override_start,
        end: override_end,
      }
    }

    post_object(endpoint, data)
  end

  # Return all users on call for all schedules, which we can parse through later
  def get_users_on_call
    endpoint = "https://#{@AUTH_HEADER[:subdomain]}.pagerduty.com/api/v1/escalation_policies/on_call/"
    return get_object(endpoint)
  end

 # Given a specific user, return all details about the
 # user that we can parse through as needed
  def get_user_details(user_id)
    endpoint = "https://#{@AUTH_HEADER[:subdomain]}.pagerduty.com/api/v1/users/#{user_id}/on_call"
    return get_object(endpoint)
  end

  # Create a page to the first person on call for a given service key
  def post_trigger(service_key:, incident_key:, description:, client:,
    client_url:, details:)
    # Ruby 2.x style kw-args is required here to make hash passing easier
    endpoint = 'https://events.pagerduty.com/generic/2010-04-15/create_event.json'
    data = {
      service_key: service_key,
      incident_key: incident_key,
      event_type: 'trigger',
      description: description,
      client: client,
      client_url: client_url,
      details: details,
    }

    post_object(endpoint, data)
  end

  private
  # Helper method for all GETs
  def get_object(endpoint)
    response = HTTParty.get(
      endpoint,
      headers: {
        'Content-Type' => 'application/json', 'Authorization' => @AUTH_HEADER[:token_string]
      }
    )
    return JSON.load(response.body)
  end

  # Helper method for all PUTs
  def post_object(endpoint, data)
    response = HTTParty.post(
      endpoint,
      body: data.to_json,
      headers: {
        'Content-Type' => 'application/json', 'Authorization' => @AUTH_HEADER[:token_string]
      }
    )

    return response.body
  end
end
