require 'httparty'
require 'json'
require 'yaml'
require 'date'
require 'trollop'
require 'pagerduty/override'
require_relative 'version'

module Tapjoy
  module PagerDuty
    class Base

      # Initializer services to import values from pg_connect.yaml
      # to configure organization-specific values (currently, subdomain and api_token)
      def initialize
        config_file = "#{ENV['PAGERDUTY_CONFIG_DIR'] ? ENV['PAGERDUTY_CONFIG_DIR'] + 'triggers.yml' : ENV['HOME'] + '/.pgutils/triggers.yaml'}"
        pg_conn = YAML.load_file(config_file) if File.readable?(config_file)

        @AUTH_HEADER = {
          :subdomain    => ENV['PAGERDUTY_SUBDOMAIN'] || pg_conn[:subdomain],
          :token_string => "Token token=#{ENV['PAGERDUTY_API_TOKEN'] || pg_conn[:api_token]}"
        }

        raise 'Missing subdomain value' if @AUTH_HEADER[:subdomain].nil?
        raise 'Missing API token' if @AUTH_HEADER[:token_string].nil?
      end

      # Given an email address return the user_id that pagerduty uses for lookups
      def get_user_id(email)
        endpoint = return_pagerduty_url(:users)
        out_array = get_object(endpoint)['users'].select { |i| i['email'].eql?(email) }
        return Hash[*out_array]['id']
      end

      # Given the name of a schedule return the schedule_id that pagerduty uses for lookups
      def get_schedule_id(schedule_name)
        endpoint = return_pagerduty_url(:schedules)
        out_array = get_object(endpoint)['schedules'].select { |i| i['name'].eql?(schedule_name)}
        return Hash[*out_array]['id']
      end

      # The set_override method takes in several variables and returns
      # the REST response upon (attempting) completion of an override action
      def set_override(query_start:, query_end:, override_start:, override_end:,
        user_id:, schedule_id:)
        # Ruby 2.x style kw-args is required here to make hash passing easier

        endpoint = "#{return_pagerduty_url(:schedules)}/#{schedule_id}/overrides?since=#{query_start}&until=#{query_end}"

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
        endpoint = return_pagerduty_url(:escalation_on_call)
        return get_object(endpoint)
      end

     # Given a specific user, return all details about the
     # user that we can parse through as needed
      def get_user_details(user_id)
        endpoint = return_pagerduty_url(:users) + "/#{user_id}/on_call"
        return get_object(endpoint)
      end

      # Create a page to the first person on call for a given service key
      def post_trigger(service_key:, incident_key:, description:, client:,
        client_url:, details:)

        # Ruby 2.x style kw-args is required here to make hash passing easier
        endpoint = return_pagerduty_url(:create_trigger)
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

      # Helper method for building PagerDuty URLs
      def return_pagerduty_url(object_type)
        rest_api_url = "https://#{@AUTH_HEADER[:subdomain]}.pagerduty.com/api/v1"
        incident_api_url = 'https://events.pagerduty.com/generic/2010-04-15'
        case object_type
        when :users
          return rest_api_url + '/users'
        when :schedules
          return rest_api_url + '/schedules'
        when :escalation_on_call
          return rest_api_url + '/escalation_policies/on_call'
        when :create_trigger
          return incident_api_url + '/create_event.json'
        else
          abort("Unknown object type: #{object_type}. Can't build URL.")
        end
      end
    end
  end
end
