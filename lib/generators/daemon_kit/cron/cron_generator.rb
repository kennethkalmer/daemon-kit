module DaemonKit
  module Generators
    class CronGenerator < Base

      def update_gemfile
        append_file 'Gemfile', "gem 'rufus-scheduler', '>= 2.0.3'\n"
      end

      def create_initializers
        directory 'config'
      end

      def create_daemon
        directory 'libexec'
      end

      protected

      def self.source_root
        File.expand_path( File.join( File.dirname(__FILE__), 'templates') )
      end
    end
  end
end
