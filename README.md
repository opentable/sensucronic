# Sensucronic

sensucronic is a wrapper for your cron jobs to integrate with
the sensu client input socket.

it's written in ruby using mixlib::cli to fit in with the rest of the
sensu ecosystem

## Installation

TODO: release gem so this works.

Add this line to your application's Gemfile:

```ruby
gem 'sensucronic'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sensucronic

## Usage

sensucronic [ OPTIONS ] [ -- ] COMMAND [ ARGS ]
sensucronic [ OPTIONS ] [ -- ] 'COMMAND [ ARGS ]'

sensucronic runs COMMAND with ARGS it generates a json report and submits
it to the sensu-client input socket

the OPTION --dryrun causes sensucronic to issue it's report to stdout
instead of the sensu client input socket.

```
prompt% sensucronic --dry-run true     
{
  "command": "true",
  "output": "",
  "status": 0,
  "exitcode": 0,
  "agent": "sensucronic"
}
```

exitcodes are propogated to sensu's status field,  0 ok, 1 warn, 2 crit, 3
unknown  but anything > 3 sets status to 3.  

TODO: add options to configure this.

```
prompt% sensucronic --dry-run 'echo hi; exit 20'
{
  "command": "echo\\ hi\\;\\ exit\\ 20",
  "output": "hi\n",
  "status": 3,
  "exitcode": 20,
  "agent": "sensucronic"
}
```

given a single quoted argument it will be parsed with a shell
otherwise it tries to exec it as command followed by arguments

```
prompt% sensucronic --dry-run  exit 3
{
  "command": "exit 3",
  "output": "Errno::ENOENT\nNo such file or directory - exit",
  "status": 3,
  "exitcode": 127,
  "agent": "sensucronic"
}
```

```
prompt% sensucronic --dry-run  'exit 3'
{
  "command": "exit\\ 3",
  "output": "",
  "status": 3,
  "exitcode": 3,
  "agent": "sensucronic"
}

```

use --help to view options
```
prompt% sensucronic --help 
Usage: sensucronic (options)
    -d, --dry-run                    output result to stdout only
    -h, --help                       print this message
    -p, --port PORT                  the port number for the sensu client input socket
    -s, --source SOURCE              set the source attribute on the sensu result
```

## TODO
- accept options to add extra fields to the output
- accept options to configure the status in response to the exitcodes.  (always warn,  always crit ) 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opentable/sensucronic

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

