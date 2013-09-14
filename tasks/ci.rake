begin

  require 'coveralls/rake/task'
  Coveralls::RakeTask.new
  task :default => [ :spec, :features, 'coveralls:push' ]

rescue LoadError
end
