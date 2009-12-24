module DaemonKit
  class Timeline

    # The timeline of every daemon's lifespan
    @sequence = [
      'framework',
      'arguments',
      'environment',
      'dependencies',
      'before_daemonize',
      'after_daemonize',
      'application',
      'shutdown'
    ].freeze

    # A list of subscribers for our timeline events.
    @subscribers = {}

    class << self

      attr_reader :sequence, :subscribers

      def execute!
        self.sequence.each do |event|
          fire_event!( event )
        end
      end

      def fire_event!( event )
        self.subscribers[event].each do |sub|
          if Proc === sub
            sub.call
          else
            sub.handle_event!( event ) if sub.respond_to?( :handle_event! )
          end
        end
      end

      def subscribe( event, object = nil, &block )
        self.subscribers[ event ] ||= []
        object = block if object.nil?
        self.subscribers[ event ].push( object )
      end

      def unsubscribe( event_or_object, object = nil )
        events = if object.nil?
          self.sequence
        else
          [ event_or_object ]
        end

        events.each do |e|
          self.subscribers[ e ].delete( object || event_or_object ) if self.subscribers[ e ]
        end
      end

      def reset!
        self.sequence.each { |e| self.subscribers[e] = [] }
      end

    end
  end
end
