begin
  require 'nanite'
rescue LoadError
  $stderr.puts "Missing nanite gem. Please run 'gem install nanite'."
  exit 1
end
