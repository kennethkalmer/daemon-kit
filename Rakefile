#!/usr/bin/env rake
require "bundler/gem_tasks"

Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
task :default => [:spec, :features]
