module DaemonKit
  module Generators
    class AppGenerator < Base
      INSTALLERS = %w( default amqp cron nanite_agent ruote xmpp )
      DEPLOYERS  = %w( capistrano )
      TEST_FRAMEWORKS = %w( none rspec test_unit )
      add_shebang_option!

      argument :app_path, :type => :string

      class_option :installer, :type => :string, :aliases => '-i', :default => 'default',
                   :desc => "Pre-configured daemon to generate (options: #{INSTALLERS.join(', ')})"

      class_option :deployer, :type => :string, :aliases => '-d',
                   :desc => "Select an optional deployment mechanism (options: #{DEPLOYERS.join(', ')})"

      class_option :test_framework, :type => :string, :aliases => '-t', :default => 'rspec',
                   :desc => "Select your prefered test framework (options: #{TEST_FRAMEWORKS.join(', ')})"

      class_option :cucumber, :type => :boolean, :aliases => '-c', :default => false,
                   :desc => "Install cucumber support"

      def initialize( *args )
        super

        unless INSTALLERS.include?( options[:installer] )
          raise Error, "Invalid value for --installer option. Supported installers are: #{INSTALLERS.join(', ')}"
        end

        if options[:deployer] && !DEPLOYERS.include?( options[:deployer] )
          raise Error, "Invalid value for --deployer option. Supported deployers are: #{DEPLOYERS.join(', ')}"
        end

        unless TEST_FRAMEWORKS.include?( options[:test_framework] )
          raise Error, "Invalid value for --test_framework option. Supported frameworks are: #{TEST_FRAMEWORKS.join(', ')}"
        end
      end

      def create_root
        self.destination_root = File.expand_path( app_path, destination_root )
        empty_directory('.')
        FileUtils.cd( destination_root )
      end

      def create_root_files
        template 'README.tt', 'README'
        copy_file 'Rakefile'
        copy_file 'Gemfile'
      end

      def create_bin_files
        empty_directory 'bin'
        template 'bin/daemon.tt', "bin/#{app_name}" do |content|
          "#{shebang}\n" + content
        end
        chmod "bin", 0755, :verbose => false
      end

      def create_config_files
        directory 'config'
      end

      def create_script_files
        directory 'script' do |content|
          "#{shebang}\n" + content
        end
        chmod 'script', 0755, :verbose => false
      end

      def create_task_directory
        empty_directory 'tasks'
      end

      def create_log_directory
        empty_directory 'log'
      end

      def create_tmp_directory
        empty_directory 'tmp'
      end

      def create_vendor_directory
        empty_directory 'vendor'
      end

      def create_lib_files
        directory 'lib'
      end

      def create_lib_exec
        case options[:installer]
        when 'default'
          directory 'libexec'
        when 'amqp'
          invoke DaemonKit::Generators::AmqpGenerator
        when 'cron'
          invoke DaemonKit::Generators::CronGenerator
        when 'nanite_agent'
          invoke DaemonKit::Generators::NaniteAgentGenerator
        when 'ruote'
          invoke DaemonKit::Generators::RuoteGenerator
        when 'xmpp'
          invoke DaemonKit::Generators::XmppGenerator
        end
      end

      def create_deployment_config
        return unless options[:deployer]

        case options[:deployer]
        when 'capistrano'
          invoke DaemonKit::Generators::CapistranoGenerator
        end
      end

      def create_test_environment
        return if options[:test_framework] == 'none'

        case options[:test_framework]
        when 'rspec'
          invoke DaemonKit::Generators::SpecGenerator
        when 'test_unit'
          invoke DaemonKit::Generators::TestUnitGenerator
        end
      end

      def create_cucumber
        return unless options.cucumber?
        invoke DaemonKit::Generators::CucumberGenerator
      end

      protected

      def self.source_root
        File.expand_path( File.join( File.dirname(__FILE__), 'templates') )
      end

    end
  end
end
