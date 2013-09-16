if ['test', 'development'].include?(DAEMON_ENV)
  require 'rspec'
  require 'rspec/core/rake_task'

  desc "Run the specs under spec/"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = ['--options', "spec/spec.opts"]
  end

  # Want other tests/tasks run by default?
  # Add them to the list
  task :default => [:spec] #, :features]
end
