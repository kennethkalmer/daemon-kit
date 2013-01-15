module DaemonKit
  module Generators
    class SpecGenerator < Base

      def update_gemfile
        append_file 'Gemfile' do
          %Q{group :development, :test do\n  gem 'rake'\n  gem 'rspec' \nend}
        end
      end

      def create_specs
        directory 'spec'
      end

      def create_task
        directory 'tasks'
      end

      protected

      def self.source_root
        File.expand_path( File.join( File.dirname(__FILE__), 'templates') )
      end
    end
  end
end
