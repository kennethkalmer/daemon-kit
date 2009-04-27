begin
  require 'xmpp4r-simple'
rescue LoadError => e
  $stderr.puts "Missing xmpp4-simple gem. Please run 'gem install xmpp4r-simple'."
  exit 1
end

