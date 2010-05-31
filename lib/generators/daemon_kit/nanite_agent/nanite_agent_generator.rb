module DaemonKit
  module Generators
    class NaniteAgentGenerator < Base

      def update_gemfile
        append_file 'Gemfile', "gem 'nanite'\n"
      end

      def create_config
        directory 'config'
      end

      def create_actors
        directory 'lib'
      end

      def create_libexec
        directory 'libexec'
      end

      protected

      def self.source_root
        File.expand_path( File.join( File.dirname(__FILE__), 'templates') )
      end

    end
  end
end
