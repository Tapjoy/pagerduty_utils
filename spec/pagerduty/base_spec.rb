require 'spec_helper'

describe Tapjoy::PagerDuty::Base do
  describe '#new' do
    it 'sets auth header' do
      auth_header = pg.instance_variable_get(:@AUTH_HEADER)
      expect(auth_header[:subdomain]).to eql expected_auth_header[:subdomain]
      expect(auth_header[:token_string]).to eql "Token token=#{expected_auth_header[:api_token]}"
    end
  end

  # This a method in pgutils, but this is the easiest way to reference it here
  # Also, in the future we probably want this method in base
  describe '#get_level_one_users' do
    it 'gets tier 1 on-call' do
      expect{
        pg.get_users_on_call['escalation_policies'].flat_map do |policy|
          policy['on_call'].map do |oncall|
            oncall['user']['id'] if oncall['start'] and oncall['level'] == 1
          end.compact
      end}.to_not raise_error
    end
  end

  # This is also in pgutils, but the situation is the same
  describe '#load_trigger' do
    it 'loads the trigger hash' do
      expect{puts **triggers[trigger_name.to_sym]}.to_not raise_error
    end
  end
end
