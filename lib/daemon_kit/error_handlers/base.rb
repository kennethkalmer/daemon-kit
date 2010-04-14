module DaemonKit
  module ErrorHandlers
    # Error handlers in DaemonKit are used by the #Safety class. Any
    # error handler has to support the interface provided by this
    # class. It's also required that safety handlers implement a
    # singleton approach (handled by default by #Base).
    class Base

      class << self

        @instance = nil

        def instance
          @instance ||= new
        end
        private :new

        # When we're inherited, immediately register the handler with
        # the safety net
        def inherited( child ) #:nodoc:
          Safety.register_error_handler( child )
        end
      end

      # Error handlers should overwrite this method and implement
      # their own reporting method.
      def handle_exception( exception )
        raise NoMethodError, "Error handler doesn't support #handle_exception"
      end
    end
  end
end
