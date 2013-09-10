require 'fileutils'
require 'stringio'

require 'rspec'

DAEMON_ENV  = "test"
DAEMON_ROOT = "#{File.dirname(__FILE__)}/../tmp"

$:.unshift( File.dirname(__FILE__) + '/../lib' )
require 'daemon_kit'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[ File.expand_path("../support/**/*.rb", __FILE__) ].each { |f| require f }

require 'genspec'

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end
