require_relative 'getpg'
require 'yaml'
require 'trollop'

def load_trigger(trigger_name)
  triggers = YAML.load_file('triggers.yaml')
  return triggers[trigger_name]
end

opts = Trollop::options do
  # Set help message
  banner <<-EOS

  This script will create a pagerduty alert, based on the name of the trigger
  hash as specified in 'triggers.yaml'

  Usage: #{ __FILE__ } [options]

  EOS

  opt :trigger, 'Name of trigger to alert on', :type => :string, :required => true
end

pg = TapJoy::PagerDuty.new
# Convert the trigger name to symbol, because that's how we are storing it
# in the triggers.yaml file.
trigger = opts[:trigger].to_sym

# Load the trigger based on the name and pass the resulting hash to
# the post_trigger method
puts pg.post_trigger(**load_trigger(trigger))
