$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'

require 'daemon_kit/initializer'
require 'daemon_kit/application'

module DaemonKit
  VERSION = '0.1.0'
end
