module Resque # :nodoc:
  module Plugins # :nodoc:
    # If you want to keep track of the number of executions per
    # Job, extend it with this module.
    #
    # Example:
    #
    #   require 'resque/plugins/stats'
    #   class HardJob
    #     extend Resque::Plugins::Stats
    #     @queue = :hard_job
    #     def self.perform(something)
    #       do_work
    #     end
    #   end
    #
    # This will keep a historical count of jobs executed *hourly*,
    # *daily* and *monthly*.
    #
    # Hourly records will only persist for 24 hours, daily will
    # be available for one month, and monthly counters will be
    # there forever.
    module Stats
      include Resque::Helpers
      # Hook that will increment the counters after the job has
      # been executed. Also, will set expiration dates for the
      # hourly and daily counters.
      def after_perform_do_stats(*args)
        Stats.increx hourly_key, 3600 * 24 # 24h
        Stats.increx daily_key, 3600 * 24 * 31 # 31d
        redis.incr monthly_key
      end

      # Returns an array of executed jobs hourly for today.
      # Indexes go from 0 to 23 hour.
      def hourly
        (0..23).collect { |h| redis.get("#{prefix_hourly}:#{Time.now.year}:#{Time.now.month}:#{Time.now.day}:#{h}").to_i }
      end

      # Returns an array of executed jobs daily for the current month.
      # Indexes go from 0 (unused) to current_month.days_in_month (max 31).
      def daily
        (0..Stats.days_in_month).collect { |d| redis.get("#{prefix_daily}:#{Time.now.year}:#{Time.now.month}:#{d}").to_i }
      end

      # Returns a hash where the key is the year/month pair and the value
      # is the count of executed jobs during that month. The format of the
      # key is "year:month" with 4 digit year and 1/2 digit month.
      def monthly
        keys = redis.keys("#{prefix_monthly}:*")
        keys.zip(redis.mget(keys)).inject({}) { |t,p| t.merge(p.first.sub("#{prefix_monthly}:", '') => p.last.to_i) }
      end

      private
      def hourly_key # :nodoc:
        "#{prefix_hourly}:#{Time.now.year}:#{Time.now.month}:#{Time.now.day}:#{Time.now.hour}"
      end

      def daily_key # :nodoc:
        "#{prefix_daily}:#{Time.now.year}:#{Time.now.month}:#{Time.now.day}"
      end

      def monthly_key # :nodoc:
        "#{prefix_monthly}:#{Time.now.year}:#{Time.now.month}"
      end

      def prefix # :nodoc:
        "plugin:stats:#{name}"
      end

      def prefix_hourly # :nodoc:
        "#{prefix}:hourly"
      end

      def prefix_daily # :nodoc:
        "#{prefix}:daily"
      end

      def prefix_monthly # :nodoc:
        "#{prefix}:monthly"
      end

      def self.days_in_month # :nodoc:
        month, year = Time.now.month, Time.now.year
        (Date.new(year,12,31) << 12 - month).day
      end

      # Increments a key even if it's volatile, by fetching it
      # first and then setting the incremented value with a new
      # expiration.
      def self.increx(key, seconds)
        tmp = Resque.redis.get key
        Resque.redis.setex key, seconds, (tmp.to_i + 1)
      end
    end
  end
end
