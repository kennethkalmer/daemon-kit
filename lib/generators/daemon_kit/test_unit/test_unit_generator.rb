module DaemonKit
  module Generators
    class TestUnitGenerator < Base

      def create_tests
        directory 'test'
      end

      def create_tasks
        directory 'tasks'
      end

      protected

      def self.source_root
        File.expand_path( File.join( File.dirname(__FILE__), 'templates') )
      end
    end
  end
end
