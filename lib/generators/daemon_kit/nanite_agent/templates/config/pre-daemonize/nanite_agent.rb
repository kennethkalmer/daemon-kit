begin
  require 'nanite'
rescue LoadError
  $stderr.puts "Missing nanite gem. Please run 'bundle install'."
  exit 1
end
