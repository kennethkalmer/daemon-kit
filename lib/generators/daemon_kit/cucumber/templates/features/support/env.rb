# Sets up the DaemonKit environment for Cucumber
ENV["DAEMON_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'daemon_kit/cucumber/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'
