require 'cucumber'

module DaemonKit
  module Generators
    class CucumberGenerator < Base
      include Thor::Actions

      add_shebang_option!

      def create_features
        directory 'features'
      end

      def create_environment
        template 'config/environments/cucumber.rb'
      end

      def create_tasks
        copy_file 'tasks/cucumber.rake'
      end

      def create_script
        copy_file 'script/cucumber' do |content|
          "#{shebang}\n" + content
        end
        chmod 'script', 0755, :verbose => false
      end

      no_tasks {

        def cucumber_version
          ::Cucumber::VERSION
        end

      }

      protected

      def self.source_root
        File.expand_path( File.join( File.dirname(__FILE__), 'templates') )
      end

    end
  end
end
