begin
  require 'amqp'
rescue LoadError
  $stderr.puts "Missing amqp gem. Please run 'bundle install'."
  exit 1
end
