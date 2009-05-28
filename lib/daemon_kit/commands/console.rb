irb = RUBY_PLATFORM =~ /(:?mswin|mingw)/ ? 'irb.bat' : 'irb'

require 'optparse'

options = { :irb => irb }
OptionParser.new do |opt|
  opt.banner = "Usage: console [environment] [options]"
  opt.on("--irb=[#{irb}]", 'Invoke a different irb.') { |v| options[:irb] = v }
  opt.on("--debugger", 'Enable ruby-debugging for the console.') { |v| options[:debugger] = v }
  opt.parse!(ARGV)
end

libs =  " -r irb/completion"
libs << %( -r "#{DAEMON_ROOT}/config/environment")
libs << " -r daemon_kit/console_daemon"

if options[:debugger]
  begin
    require 'ruby-debug'
    libs << " -r ruby-debug"
    puts "=> Debugger enabled"
  rescue Exception
    puts "You need to install ruby-debug to run the console in debugging mode. With gems, use 'gem install ruby-debug'"
    exit
  end
end

ENV['DAEMON_ENV'] = case ARGV.first
  when "p"; "production"
  when "d"; "development"
  when "t"; "test"
  else
    ARGV.first || ENV['DAEMON_ENV'] || 'development'
end

puts "Loading #{ENV['DAEMON_ENV']} environment (daemon-kit #{DaemonKit::VERSION})"

exec "#{options[:irb]} #{libs} --simple-prompt"
