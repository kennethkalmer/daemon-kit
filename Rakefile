Dir['tasks/**/*.rake'].each { |t| load t }

require File.dirname(__FILE__) + '/lib/daemon_kit'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'daemon-kit'
    gemspec.version = DaemonKit::VERSION
    gemspec.summary = 'Opinionated framework for Ruby daemons'
    gemspec.description = 'daemon-kit aims to simplify creating Ruby daemons by providing a sound application skeleton (through a generator), task specific generators (jabber bot, etc) and robust environment management code.'
    gemspec.email = 'kenneth.kalmer@gmail.com'
    gemspec.homepage = 'http://github.com/kennethkalmer/daemon-kit'
    gemspec.authors = ['kenneth.kalmer@gmail.com']
    gemspec.post_install_message = IO.read('PostInstall.txt')
    gemspec.extra_rdoc_files.include '*.txt'
    gemspec.files.include("lib/generators/**/*", "lib/daemon_kit/vendor/**/*")

    gemspec.add_dependency 'eventmachine', '>=0.12.10'
    gemspec.add_development_dependency 'rspec'
    gemspec.add_development_dependency 'cucumber'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with 'gem install jeweler'"
end

# TODO - want other tests/tasks run by default? Add them to the list
task :default => [:spec] #, :features]
