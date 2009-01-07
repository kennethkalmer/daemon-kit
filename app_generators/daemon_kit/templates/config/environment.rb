# Be sure to restart your daemon when you modify this file

# Uncomment below to force your daemon into production mode
ENV['DAEMON_ENV'] ||= 'production'

# Boot up
require File.join(File.dirname(__FILE__), 'boot')

DaemonKit::Initializer.run do |config|
end
