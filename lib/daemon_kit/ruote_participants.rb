module DaemonKit
  # Class that cleanly abstracts away the different remote participants in
  # ruote and allows daemon writers to just worry about processing workitems
  # without worrying over the transport mechanism or anything else...
  class RuoteParticipants

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
      @runtime_queues = []

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

    # Register classes as pseudo-participants. Two styles of registration are
    # supported:
    #
    #   register( Foo )
    #   register( 'short', ShortParticipant )
    #
    # The first format uses the class name (downcased and underscored) as the
    # key for identifying the pseudo-participant, the second uses the the
    # provided key.
    #
    # Pseudo-participant classes are instantiated when registered, and the
    # instances are re-used.
    def register( *args )
      key, klass = if args.size == 1
        [ underscore( args.first.to_s ), args.first ]
      else
        [ args[0].to_s, args[1] ]
      end

      @participants[ key ] = klass.new
    end

    # Run the participants
    def run(&block)
      run_amqp! if @transports.include?( :amqp )
    end

    # Subscribe to additional queues not specified in ruote.yml
    def subscribe_to( queue )
      @runtime_queues << queue
    end

    private

    def run_amqp!
      AMQP.run do
        mq = ::MQ.new
        queues = @configuration['amqp']['queues'].to_a | @runtime_queues

        queues.each do |q|
          DaemonKit.logger.debug("Subscribing to #{q} for workitems")

          cmdq = mq.queue( q, :durable => true )
          cmdq.subscribe( :ack => true ) do |header, message|
            safely do
              DaemonKit.logger.debug("Received workitem: #{message.inspect}")

              RuoteWorkitem.process( :amqp, message )

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
