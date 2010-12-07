$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "resque-stats"
  s.version     = "0.1.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jordi Romero"]
  s.email       = ["jordi@jrom.net"]
  s.homepage    = "http://github.com/jrom/resque-stats"
  s.summary     = %q{Keep track of the number of executions for a Resque job}
  s.description = %q{If you want to graph the workload created by your different Resque jobs, extend them with this plugin and use the data generated to know exactly the amount of jobs executed.}

  s.files         = `git ls-files`.split("\n") - %w(.gitignore .rspec)
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "resque", "~> 1.10.0"
  s.add_development_dependency "rspec", "~> 2.2.0"

end
