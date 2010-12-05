# Resque::Plugins::Stats

<http://github.com/jrom/resque-stats> by Jordi Romero

If you want to keep track of the number of executions per
Job, extend it with this module.

## Usage

    require 'resque/plugins/stats'
    class HardJob
      extend Resque::Plugins::Stats
      @queue = :hard_job
      def self.perform(something)
        do_work
      end
    end

This will keep a historical count of jobs executed *hourly*,
*daily* and *monthly*.

### Hourly

`HardJob.hourly` will return an array with the count of jobs executed
every hour during **today**. Indexes go from 0 to 23 hour.

### Daily

`HardJob.daily` will return an array with the count of jobs executed
every day during the **current month**. Indexes go from 0 (unused)
to current_month.days_in_month (max 31).

### Monthly

`HardJob.monthly` will return a hash with the count of jobs executed
every month. The key is the year/month pair and the value is the count
of executed jobs during that month. The format of the key is "year:month"
with 4 digit year and 1/2 digit month.

## Example

    Resque.enque HardJob, 123
    # Work this job...
    Time.now
    # => Mon Dec 06 00:34:12 +0100 2010
    HardJob.hourly
    # => [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    HardJob.daily
    # => [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    HardJob.monthly
    # => {"2010:12"=>1}

## Contributing

If you want to improve resque-stats

1. Fork the repo
2. Create a topic branch `git checkout -b my_feature`
3. Push it! `git push origin my_feature`
4. Open a pull request

Make sure you add specs for your changes and document them.
Any contribution will be appreciated, both fixing some typo or
adding the coolest feature ever.

## Issues

<http://github.com/jrom/resque-stats/issues>
