begin
  require 'rufus/scheduler'
rescue LoadError => e
  $stderr.puts "Missing rufus-scheduler gem. Please run 'bundle install'."
  exit 1
end

if Rufus::Scheduler::VERSION < "2.0.0"
  $stderr.puts "Requires rufus-scheduler-2.0.0 or later"
  exit 1
end
