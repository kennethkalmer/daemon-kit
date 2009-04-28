$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'

module DaemonKit
  VERSION = '0.1.2'
  
  autoload :Initializer, 'daemon_kit/initializer'
  autoload :Application, 'daemon_kit/application'
  autoload :Cron,        'daemon_kit/cron'
  autoload :Jabber,      'daemon_kit/jabber'
  autoload :AMQP,        'daemon_kit/amqp'
end
