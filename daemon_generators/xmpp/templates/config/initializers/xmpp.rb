begin
  require 'blather'
rescue LoadError
  $stderr.puts "Missing blather gem. Please run 'gem install amqp'."
  exit 1
end
