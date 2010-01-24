DAEMON_ENV = 'test' unless defined?( DAEMON_ENV )

require 'test/unit'

require File.dirname(__FILE__) + '/../config/environment'
DaemonKit::Application.running!
