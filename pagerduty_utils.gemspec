Gem::Specification.new do |s|
  s.name        = 'pagerduty_utils'
  s.version     = '0.1.1'
  s.date        = '2014-11-25'
  s.summary     = 'TapJoy PagerDuty Tools'
  s.description = 'A set of tools to make leveraging the PagerDuty APIs easier'
  s.authors     = ['Ali Tayarani']
  s.email       = 'ali.tayarani@tapjoy.com'
  s.files       = ['lib/pagerduty/base.rb', 'lib/pagerduty/override.rb']
  s.homepage    = 'https://github.com/tapjoy/pagerduty_utils'
  s.license     = 'MIT'
  s.executables = ['pgutils']
  s.add_runtime_dependency 'trollop', '>= 2.1'
  s.add_runtime_dependency 'httparty'
end
