require 'thor/group'

module DaemonKit
  module Generators
    class Error < Thor::Error
    end

    class Base < Thor::Group
      include Thor::Actions

      add_runtime_options!

      # Tries to get the description from a USAGE file one folder above the source
      # root otherwise uses a default description.
      def self.desc(description=nil)
        return super if description
        usage = File.expand_path(File.join(source_root, "..", "USAGE"))

        @desc ||= if File.exist?(usage)
          File.read(usage)
        else
          "Description:\n    Create #{base_name.humanize.downcase} files for #{generator_name} generator."
        end
      end

      protected

      def app_name
        @app_name = File.basename( destination_root )
      end

      # Small macro to add ruby as an option to the generator with proper
      # default value plus an instance helper method called shebang.
      #
      def self.add_shebang_option!
        class_option :ruby, :type => :string, :aliases => "-r", :default => Thor::Util.ruby_command,
                            :desc => "Path to the Ruby binary of your choice", :banner => "PATH"

        no_tasks {
          define_method :shebang do
            @shebang ||= begin
              command = if options[:ruby] == Thor::Util.ruby_command
                "/usr/bin/env #{File.basename(Thor::Util.ruby_command)}"
              else
                options[:ruby]
              end
              "#!#{command}"
            end
          end
        }
      end

      def self.namespace(name = nil)
        return super if name
        @namespace ||= super.sub(/_generator$/, '').sub(/:generators:/, ':').sub(/^daemon_kit:/, '')
      end

    end
  end
end
