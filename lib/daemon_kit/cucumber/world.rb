# -*- coding: utf-8 -*-
# Based on code from Brian Takita, Yurii Rashkovskii, Ben Mabey and Aslak Hellesøy
# Adapted by Kenneth Kalmer for daemon-kit

begin
  require 'test/unit/testresult'
rescue LoadError => e
  e.message << "\nYou must gem install test-unit. For more info see https://rspec.lighthouseapp.com/projects/16211/tickets/292"
  raise e
end

# So that Test::Unit doesn't launch at the end - makes it think it has already been run.
Test::Unit.run = true if Test::Unit.respond_to?(:run=)

$__cucumber_toplevel = self

module DaemonKit
  module Cucumber
    # All scenarios will execute in the context of a new instance of World.
    class World
      def initialize #:nodoc:
        @_result = Test::Unit::TestResult.new
      end
    end

    $__cucumber_toplevel.Before do
      # Placeholder
    end

    $__cucumber_toplevel.After do
      # Placeholder
    end
  end
end

World do
  DaemonKit::Cucumber::World.new
end
