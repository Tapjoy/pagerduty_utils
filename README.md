PagerDuty Tools
===

## Requirements
* Ruby 2.1
* Httparty gem

## Configuration

There are two config files that are currently used by this application.  The default location for these files is $HOME/.pgtools/ ; however, this can be overridden, using the ```$PAGERDUTY_CONFIG``` environment variable

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
  :service_key:  # Service key associated with Trigger
  :incident_key: # Incident key to apply to trigger
  :description:  # Description that should be in triggered message
  :client:       # Name of client to trigger on
  :client_url:   # URL of client to report on
  :details:      # Trigger details
```

Repeat above block once for each trigger (use different trigger names for each trigger)

## Commands
### set_override

This code is used to temporarily override the primary person on-call for a given schedule.

```
Usage: pgtools set_override [options]
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
Usage: pgtools get_on_call
```

### trigger

This script will create a pagerduty alert, based on the name of the trigger
hash as specified in 'triggers.yaml'

```
  Usage: pgtools trigger [options]
  --trigger, -t <s>:   Name of trigger to alert on
         --help, -h:   Show this message
```

## Example Uses
### Getting help from a continuous deployment page

Recently, we’ve started to migrate from set deploy slots run by the DevOps team to an on-demand deployment system used by developers.  The system we’ve set up is a push button based website, but has left us with an interesting problem: what’s the best way for developers to reach out to a point of contact in DevOps?

By connecting the ```pgtools trigger``` command to a button on the deployment website, developers can click and instantly page the first person on-call.

For a less intrusive system, we can simply return a list of everyone on-call, and let the developers work out who the appropriate contact will be (using the ```pgtools get_on_call``` command):

```ruby
pg = TapJoy::PagerDuty::Base.new
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

Another problem with having developer-run deployments is assigning accountability to those developers, so they will be aware if their deploy manages to go awry.  To this end, we can use the ```pgtools set_override``` command.

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
