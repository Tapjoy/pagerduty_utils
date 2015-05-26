PagerDuty Utils
===

[![Gem Version](https://badge.fury.io/rb/pagerduty_utils.svg)](http://badge.fury.io/rb/pagerduty_utils)
[![Code Climate](https://codeclimate.com/github/Tapjoy/pagerduty_utils/badges/gpa.svg)](https://codeclimate.com/github/Tapjoy/pagerduty_utils)
[![Gem](https://img.shields.io/gem/dt/pagerduty_utils.svg)](https://rubygems.org/gems/pagerduty_utils/)

These PagerDuty Utils are a set of tools used by the Tapjoy DevOps team to integrate PagerDuty into our internal developer-facing applications.

In its current form, it provides access to three areas of PagerDuty -- setting an on-call override, getting a list of who is on-call, and triggering an alert.  The syntax for these commands is listed in the Commands section.  For a set of example uses, you can turn to this blog post:  <Insert Blog Post Here>

## Requirements
* Ruby 2.1
* Httparty gem

## Installation
### Installation from RubyGems
```
gem install pagerduty_utils
```
### Installation from source
```
git clone git@github.com:Tapjoy/pagerduty_utils.git
cd pagerduty_utils
gem build pagerduty_utils.gemspec
gem install pagerduty_utils*.gem --no-ri --no-rdoc
cd ..
```

## Configuration

There are two config files that are currently used by this application.  The default location for these files is $HOME/.pgutils/ ; however, this can be overridden, using the ```$PAGERDUTY_CONFIG_DIR``` environment variable

### pg_connect.yaml

This config file provides API connection information to connect to the PagerDuty APIs

```yaml
:subdomain: # subdomain used for PagerDuty access
:api_token: # API token allocated in PagerDuty for use of these scripts
```

Alternatively, these parameters can be specified in your environment as ```$PAGERDUTY_SUBDOMAIN``` and ```$PAGERDUTY_API_TOKEN```, respectively.

### triggers.yaml

This config file provides required settings to post triggers to the PagerDuty integration API.  At this point, this config file is *required* to interact with the `trigger` subcommand.

```yaml
:<Name of Trigger>:
  :service_key:  # Service (API) key associated with Trigger. Required Field.
  :incident_key: # Incident key to apply to trigger for tracking. Required Field.
  :description:  # Description that should be in triggered message. Required Field.
  :client:       # Name of client to trigger on
  :client_url:   # URL of client to report on
  :details:      # Trigger details
```

Repeat above block once for each trigger (use different trigger names for each trigger)

## Commands
### set_override

This code is used to temporarily override the primary person on-call for a given schedule.

```
Usage: pgutils set_override [options]
            --email, -e <s>:   Specify email address of override user
    --schedule-name, -n <s>:   Name of schedule to override (default: Default)
  --override-length, -t <i>:   Number of seconds to maintain override for
                               (default: 3600)
                 --help, -h:   Show this message
```

### get_on_call

This code will return all people who are tier 1 support on-call, and will additionally return
all schedules that they are on-call for.  There are no parameters for this script.

```
Usage: pgutils get_on_call
```

### trigger

This script will create a pagerduty alert, based on the name of the trigger
hash as specified in 'triggers.yaml'

```
  Usage: pgutils trigger [options]
  --trigger, -t <s>:   Name of trigger to alert on
         --help, -h:   Show this message
```

### audit

By default, this script will return the last 30 days of pages or last 100 pages, which ever is fewer.  There are parameters to adjust the date range, but 100 pages is still the cap.

For more information on the output of this command: https://developer.pagerduty.com/documentation/rest/incidents/list

```
  Usage: pgutils audit

  Options:
    -s, --since=<i>    Get list of incidents since the given time window in days (default: 30)
    -u, --until=<i>    Get list of incidents until the given time window in days relative to since parameter (default: 30)
    -h, --help         Show this message
```

## Example Uses
### Getting help from a continuous deployment page

Recently, we’ve started to migrate from set deploy slots run by the DevOps team to an on-demand deployment system used by developers.  The system we’ve set up is a push button based website, but has left us with an interesting problem: what’s the best way for developers to reach out to a point of contact in DevOps?

By connecting the ```pgutils trigger``` command to a button on the deployment website, developers can click and instantly page the first person on-call.

For a less intrusive system, we can simply return a list of everyone on-call, and let the developers work out who the appropriate contact will be (using the ```pgutils get_on_call``` command):

```ruby
pg = Tapjoy::PagerDuty::Base.new
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

### Assigning accountability to the deployer

Another problem with having developer-run deployments is assigning accountability to those developers, so they will be aware if their deploy manages to go awry.  To this end, we can use the ```pgutils set_override``` command.

By passing options into the script, we can easily assign someone to the on-call schedule based on project and user’s email (which are already recorded):

```ruby
'set_override' => OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename(__FILE__)} set_override [options]"
  opts.on('-e', '--email EMAIL', 'Specify email address of override user') do |e|
    options[:email] = e
  end
  opts.on('-s', '--schedule-name SCHEDULE', 'Name of schedule to override') do |s|
    options[:schedule_name] = s
  end
  opts.on('-t', '--override-length TIME', 'Number of seconds to maintain override for') do |t|
    options[:override_length] = t
  end
end
```

## Contributing

If you are interested in developing against this repo, follow these steps:

1. Fork the repo
2. Copy your yaml files that you use at runtime to specs/fixtures.
3. Create a new PR with your new code and tests
