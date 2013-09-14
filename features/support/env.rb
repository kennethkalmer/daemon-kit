begin
  require 'coveralls'
  Coveralls.wear_merged!
rescue LoadError
end

require 'rspec'

DAEMON_ENV = "test"

$:.unshift File.expand_path( '/../lib', __FILE__ )
require 'daemon_kit'

require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 5
end
