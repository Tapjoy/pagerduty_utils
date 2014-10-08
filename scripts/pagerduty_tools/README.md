PagerDuty Tools
----------------

# Requirements
* Ruby 2.1
* Trollop gem
* Httparty gem

# Scripts
## set_override.rb

This code is used to temporarily override the primary person on-call for a given schedule.

```
Usage: set_override.rb [options]
            --email, -e <s>:   Specify email address of override user
    --schedule-name, -n <s>:   Name of schedule to override (default: Default)
  --override-length, -t <i>:   Number of seconds to maintain override for
                               (default: 3600)
                 --help, -h:   Show this message
```

## get_on_call.rb

This code will return all people who are tier 1 support on-call, and will additionally return
all schedules that they are on-call for.  There are no parameters for this script.

```
Usage: get_on_call.rb
```

## post_trigger.rb

This script will create a pagerduty alert, based on the name of the trigger
hash as specified in 'triggers.yaml'

```
  Usage: post_trigger.rb [options]
  --trigger, -t <s>:   Name of trigger to alert on
         --help, -h:   Show this message
```
