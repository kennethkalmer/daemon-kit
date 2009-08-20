require 'test/unit'
require 'timeout'
require 'shoulda'
require 'mocha'

require File.dirname(__FILE__) + '/../config/environment'
DaemonKit::Application.running!
