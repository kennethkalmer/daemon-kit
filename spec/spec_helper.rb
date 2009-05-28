require 'rubygems'
gem 'rspec'
require 'spec'

require 'mocha'
require 'fileutils'

DAEMON_ENV  = "test"
DAEMON_ROOT = "#{File.dirname(__FILE__)}/../tmp"

$:.unshift( File.dirname(__FILE__) + '/../lib' )
require 'daemon_kit'

Spec::Runner.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # setup a fake daemon_root
  config.before(:all) { File.directory?( DAEMON_ROOT ) ? FileUtils.rm_rf("#{DAEMON_ROOT}/*") : FileUtils.mkdir_p( DAEMON_ROOT ) }
  config.after(:all) { FileUtils.rm_rf("#{DAEMON_ROOT}/*") }
end
