begin
  require 'rufus-scheduler'
rescue LoadError => e
  $stderr.puts "Missing rufus-scheduler gem. Please run 'gem install rufus-scheduler'."
  exit 1
end

