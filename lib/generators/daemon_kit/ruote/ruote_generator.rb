module DaemonKit
  module Generators
    class RuoteGenerator < Base

      def update_gemfile
        append_file 'Gemfile', "gem 'amqp' # Only needed if running the AMQP participant/listener pair\n"
        append_file 'Gemfile', "gem 'json' # Can be replaced with json_pure\n"
      end

      def create_configs
        directory 'config'
      end

      def create_lib
        directory 'lib', nil, :force => true
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
