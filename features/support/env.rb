require 'rspec'

DAEMON_ENV = "test"

$:.unshift File.expand_path( '/../lib', __FILE__ )
require 'daemon_kit'

require 'aruba/cucumber'
