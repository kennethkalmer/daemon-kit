require 'daemon_kit/generators'
DaemonKit::Generators.configure!

if ARGV.size == 0
  DaemonKit::Generators.help
  exit
end

name = ARGV.shift
DaemonKit::Generators.invoke name, ARGV, :behaviour => :invoke, :destination_root => DaemonKit.root
