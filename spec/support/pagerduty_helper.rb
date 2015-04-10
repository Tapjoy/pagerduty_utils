require 'active_support/concern'

module PagerdutyHelper
  extend ActiveSupport::Concern

  included do
    let(:pg)                          { Tapjoy::PagerDuty::Base.new }
    ENV['PAGERDUTY_CONFIG_DIR'] = 'spec/fixtures/'
    let(:expected_auth_header)        {YAML.load_file("#{ENV['PAGERDUTY_CONFIG_DIR']}/pgconnect.yml")}
    let(:triggers)                    {YAML.load_file("#{ENV['PAGERDUTY_CONFIG_DIR']}/triggers.yml")}
    let(:trigger_name)                {'test'}
  end
end
