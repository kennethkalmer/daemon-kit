begin
  require 'json'
rescue LoadError
  $stderr.puts "Missing json gem. Please run 'gem install json'"
  exit 1
end

begin
  require 'amqp'
  require 'mq'
rescue LoadError
  $stderr.puts "Missing amqp gem. Please run 'gem install amqp' if you wish to use the AMQP participant/listener pair in ruote"
end
