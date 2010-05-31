# TODO: Don't always depend on bundled thor
$:.unshift File.dirname(__FILE__) + '/vendor/thor-0.13.6/lib'

require 'daemon_kit/generators/base'

module DaemonKit
  module Generators
    autoload :AppGenerator,         'generators/daemon_kit/app/app_generator'
    autoload :CucumberGenerator,    'generators/daemon_kit/cucumber/cucumber_generator'
    autoload :AmqpGenerator,        'generators/daemon_kit/amqp/amqp_generator'
    autoload :CronGenerator,        'generators/daemon_kit/cron/cron_generator'
    autoload :CapistranoGenerator,  'generators/daemon_kit/capistrano/capistrano_generator'
    autoload :NaniteAgentGenerator, 'generators/daemon_kit/nanite_agent/nanite_agent_generator'
    autoload :SpecGenerator,        'generators/daemon_kit/rspec/rspec_generator'
    autoload :TestUnitGenerator,    'generators/daemon_kit/test_unit/test_unit_generator'
    autoload :RuoteGenerator,       'generators/daemon_kit/ruote/ruote_generator'
    autoload :XmppGenerator,        'generators/daemon_kit/xmpp/xmpp_generator'

    class << self

      def configure!
      end

      def invoke( namespace, args = ARGV, config = {} )
        klass_name = constants.detect do |sym|
          klass = const_get( sym )
          klass.respond_to?( :namespace ) && klass.namespace == namespace
        end

        if klass_name.nil?
          raise Error, "Could not find generator #{namespace}."
        end

        klass = const_get( klass_name )

        args << '--help' if args.empty? && klass.arguments.any? { |a| a.required? }
        klass.start( args, config )
      end

      def help
        namespaces = constants.inject([]) do |list, sym|
          unless sym == :Base || sym == :AppGenerator
            klass = const_get( sym )
            list << klass.namespace if klass.respond_to?( :namespace )
          end

          list
        end

        puts "Usage:"
        puts "  script/generate GENERATOR [args] [options]"
        puts
        puts "General options:"
        puts "  -h, [--help]     # Print generators options and usage"
        puts "  -p, [--pretend]  # Run but do not make any changes"
        puts "  -f, [--force]    # Overwrite files that already exist"
        puts "  -s, [--skip]     # Skip files that already exist"
        puts "  -q, [--quiet]    # Supress status output"
        puts
        puts "Available generators:"

        namespaces.each { |ns| puts "  " + ns }
        puts
      end
    end
  end
end
