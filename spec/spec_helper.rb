Bundler.require(:default, :development)
require 'lib/resque/plugins/stats'

RSpec.configure do |config|
  config.before(:all) do
    if !system('which redis-server')
      puts "\ncan't find `redis-server` in your path"
      abort
    end
    `redis-server #{File.dirname(File.expand_path(__FILE__))}/redis-test.conf` # run Redis with local config
    puts  "Starting test redis server: redis-server #{File.dirname(File.expand_path(__FILE__))}/redis-test.conf"
    Resque.redis = 'localhost:6378' # port specified in redis-test.conf
  end

  config.before(:each) do
    Resque.redis.flushall # Drop all keys between examples
  end

  config.after(:all) do
    pid = `ps -e -o pid,command | grep [r]edis-test`.split(" ")[0]
    puts "\nKilling test redis server PID #{pid}..."
    `rm -f #{File.dirname(File.expand_path(__FILE__))}/dump.rdb` # file specified in redis-test.conf
    Process.kill("KILL", pid.to_i)
  end
end
