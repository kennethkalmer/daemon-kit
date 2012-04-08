begin
  require 'rspec'
  require 'rspec/core/rake_task'
rescue LoadError
  puts <<-EOS
To use rspec for testing you must install rspec gem:
    gem install rspec
EOS
end

begin
  require 'rspec/core/rake_task'

  desc "Run the specs under spec/"
  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = ['--options', "spec/spec.opts"]
  end
rescue NameError, LoadError
  # No loss, warning printed already
end
