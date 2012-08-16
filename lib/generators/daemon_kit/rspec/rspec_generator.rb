module DaemonKit
  module Generators
    class SpecGenerator < Base

      def update_gemfile
        append_file 'Gemfile', "group :development, :test do\n  gem 'rspec'\nend\n"
        append_file 'Gemfile', <<-GEM
group :development, :test do
  gem 'rake'
  gem 'rspec'
end
GEM
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
