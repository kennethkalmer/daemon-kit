module DaemonKit
  # Class that cleanly abstracts away the different remote participants in
  # ruote and allows daemon writers to just worry about processing workitems
  # without worrying over the transport mechanism or anything else...
  class RuoteParticipant

    class << self

      # Configure this daemon as a remote participant to ruote.
      def configure(&block)
        instance.configure(&block)
      end

      # Activate and run the remote participant code, calling the optional
      # block for additional daemon logic.
      def run(&block)
        instance.run(&block)
      end

      private :new

      def instance
        @instance ||= new
      end

      private

      def instance=( obj )
        @instance = obj
      end
    end

    attr_reader :participants

    def initialize
      @transports = []
      @participants = {}

      @configuration = Config.load('ruote')
    end

    # Yields +self+ and configures the remote participants
    def configure(&block)
      block.call( self )

      @transports.freeze
      @participants.freeze
    end

    # Enable the use of a specific transport for workitems. Can be :amqp to use
    # the AMQPParticipant/AMQPListener pair in ruote.
    def use( transport )
      @transports << transport
    end

    # Register classes for work
    def register( klass )
      key = underscore( klass.to_s )

      @participants[ key ] = klass.new
    end

    # Run the participants
    def run(&block)
      run_amqp! if @transports.include?( :amqp )
    end

    private

    def run_amqp!
      AMQP.run do
        mq = ::MQ.new
        queues = @configuration['amqp']['queues'].to_a

        queues.each do |q|
          DaemonKit.logger.debug("Subscribing to #{q} for workitems")

          cmdq = mq.queue( q, :durable => true )
          cmdq.subscribe( :ack => true ) do |header, message|
            safely do
              DaemonKit.logger.debug("Received workitem: #{message.inspect}")

              Workitem.process( :amqp, message )

              DaemonKit.logger.debug("Processed workitem.")

              header.ack
            end
          end
        end
      end
    end

    # Shamelessly lifted from the ActiveSupport inflector
    def underscore(camel_cased_word)
      camel_cased_word.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end
  end
end
