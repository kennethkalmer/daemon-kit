begin
  require 'blather'
rescue LoadError
  $stderr.puts "Missing blather gem. Please run 'bundle install'."
  exit 1
end
