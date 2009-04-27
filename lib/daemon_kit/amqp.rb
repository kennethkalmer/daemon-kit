require 'yaml'

module DaemonKit
  # Thin wrapper around the amqp gem, specifically designed to ease
  # configuration of a AMQP consumer daemon and provide some added
  # simplicity
  class AMQP

    @@instance = nil

    class << self

      def instance
        @instance ||= (
          config = YAML.load_file( "#{DAEMON_ROOT}/config/amqp.yml" )[DAEMON_ENV]
          raise ArgumentError, "Missing AMQP configuration for #{DAEMON_ENV} environment" if config.nil?
          new( config )
        )
      end

      private :new

      def run(&block)
        instance.run(&block)
      end
    end

    def initialize( config = {} )
      @config = config.inject({}) { |m,c| m[c[0].to_sym] = c[1]; m } # symbolize_keys 
    end

    def run(&block)
      # Ensure graceful shutdown of the connection to the broker
      DaemonKit.trap('INT') { ::AMQP.stop { ::EM.stop } }
      DaemonKit.trap('TERM') { ::AMQP.stop { ::EM.stop } }

      # Start our event loop
      ::AMQP.start(@config, &block)
    end
  end
end
