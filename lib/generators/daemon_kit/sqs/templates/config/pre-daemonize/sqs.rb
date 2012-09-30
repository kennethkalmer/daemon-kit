begin
  require 'aws-sdk'
rescue LoadError
  $stderr.puts "Missing aws-sdk gem. Please run 'bundle install'."
  exit 1
end
