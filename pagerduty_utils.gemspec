require File.expand_path('../lib/tapjoy/pagerduty/version', __FILE__)
Gem::Specification.new do |s|
  s.name        = 'pagerduty_utils'
  s.version     = Tapjoy::PagerDuty::VERSION
  s.date        = '2015-05-26'
  s.summary     = 'Tapjoy PagerDuty Tools'
  s.description = 'A set of tools to make leveraging the PagerDuty APIs easier'
  s.authors     = ['Ali Tayarani', 'Ed Healy']
  s.email       = 'ali.tayarani@tapjoy.com'
  s.files       = Dir['lib/tapjoy/**/**']
  s.homepage    = 'https://github.com/tapjoy/pagerduty_utils'
  s.license     = 'MIT'
  s.executables = ['pgutils']
  s.add_runtime_dependency 'trollop', '>= 2.1'
  s.add_runtime_dependency 'httparty'
  s.add_development_dependency 'rspec', '>= 3.2'
  s.add_development_dependency 'activesupport', '~> 4.2'
end
