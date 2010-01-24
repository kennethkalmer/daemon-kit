module DaemonKit
  module Generators
    class CapistranoGenerator < Base

      def create_capfile
        copy_file 'Capfile'
      end

      def create_config
        directory 'config'
      end

      protected

      def self.source_root
        File.expand_path( File.join( File.dirname(__FILE__), 'templates') )
      end

    end
  end
end
