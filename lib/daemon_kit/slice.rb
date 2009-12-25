module DaemonKit
  module Slice

    def self.included( base )
      base.send( :include, InstanceMethods )
      base.extend( ClassMethods )
    end

    module ClassMethods

      attr_accessor :callbacks

      def on( event, &block )
        self.callbacks ||= {}
        self.callbacks[ event.to_s ] ||= []
        self.callbacks[ event.to_s ] << block
      end
    end

    module InstanceMethods
      def handle_event!( event_name )

        self.class.callbacks[ event_name.to_s ].each do |callback|
          instance_eval( &callback )
        end if self.class.callbacks && self.class.callbacks[ event_name.to_s ]

        self.send( event_name ) if self.respond_to?( event_name )
      end
    end

  end
end
