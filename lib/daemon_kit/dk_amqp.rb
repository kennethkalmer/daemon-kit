require 'yaml'
require 'mq'

module DaemonKit
  # Thin wrapper around the amqp gem, specifically designed to ease
  # configuration of a AMQP consumer daemon and provide some added
  # simplicity
  class AMQP

    @@instance = nil

    class << self

      def instance
        @instance ||= new
      end

      private :new

      def run(&block)
        instance.run(&block)
      end
    end

    def initialize( config = {} )
      @config = DaemonKit::Config.load('amqp').to_h( true )
    end

    def run(&block)
      # Ensure graceful shutdown of the connection to the broker
      DaemonKit.trap('INT') { ::AMQP.stop { ::EM.stop } }
      DaemonKit.trap('TERM') { ::AMQP.stop { ::EM.stop } }

      # Start our event loop and AMQP client
      DaemonKit.logger.debug("AMQP.start(#{@config.inspect})")
      ::AMQP.start(@config, &block)
    end
  end
end
