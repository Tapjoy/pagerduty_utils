ops-toolbox
===========

This repository that contains scripts and utilities used by Tapjoy Operations on a routine basis.  In the future, we anticipate adding code that assists with AWS, GitHub, and generalized Linux management.

## Table of Contents
- [Scripts](#Scripts)
  - [PagerDuty Tools](#pagerduty-tools)
- [License](#License)

## Scripts
### PagerDuty Tools
For more information, please refer to the [Readme](https://github.com/Tapjoy/ops-toolbox/blob/master/scripts/pagerduty_tools/README.md).
#### Example Uses
##### Getting help from a continuous deployment page

Recently, we’ve started to migrate from set deploy slots run by the DevOps team to an on-demand deployment system used by developers.  The system we’ve set up is a push button based website, but has left us with an interesting problem: what’s the best way for developers to reach out to a point of contact in DevOps?

By connecting the ```post_trigger.rb``` script to a button on the deployment website, developers can click and instantly page the first person on-call.

For a less intrusive system, we can simply return a list of everyone on-call, and let the developers work out who the appropriate contact will be (using the ```get_on_call.rb``` script):

```ruby
pg = TapJoy::PagerDuty.new
get_level_one_users(pg).each do |u|
  user = pg.get_user_details(u)['user']
  on_call = user['on_call']
  puts "Name: #{user['name']}"
  on_call.each do |oc|
    puts "\tGroup: #{oc['escalation_policy']['name']}"
    puts "\tStart: #{oc['start']}"
    puts "\tEnd: #{oc['end']}"
    puts "\n"
  end
  puts '---'
end
```

##### Assigning accountability to the deployer

Another problem with having developer-run deployments is assigning accountability to those developers, so they will be aware if their deploy manages to go awry.  To this end, we can use the ```set_override.rb``` script.

By passing options into the script, we can easily assign someone to the on-call schedule based on project and user’s email (which are already recorded):

```ruby
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
```

## License

The MIT License (MIT)

Copyright (c) 2014 Tapjoy, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
