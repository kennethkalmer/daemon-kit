module DaemonKit
  # Provides a wrapper for running code inside a 'safety net' Any
  # exceptions raised inside a safety net is handled and reported via
  # loggers, email or Hoptoad.
  #
  # The safety net can be configured via DaemonKit.config.safety,
  # which holds the only instance of the safety net.
  class Safety

    # Who get's notified.
    @handler = nil
    attr_accessor :handler

    # Registered error handlers
    @error_handlers = {}
    attr_reader :error_handlers

    class << self

      # Singleton
      @instance = nil

      def instance
        @instance ||= new
      end
      private :new

      # Run the provided block inside a safety net.
      def run(&block)
        self.instance.run(&block)
      end

      def register_error_handler( klass )
        name = klass.to_s.split('::').last.downcase

        DaemonKit.logger.debug( "Registering error handler '#{name}' (#{klass})" ) if DaemonKit.logger

        instance.instance_eval( <<-EOF, __FILE__, __LINE__ )
        def #{name}
          @#{name} ||= #{klass}.instance
        end
        EOF
      end
    end

    # Run the provided block inside a safety net.
    def run(&block)
      begin
        block.call
      rescue => e
        # Log
        DaemonKit.logger.fatal "Safety net caught exception: #{e.message}"
        DaemonKit.logger.fatal "Backtrace: #{e.backtrace.join("\n    ")}"

        get_handler.handle_exception( e ) if get_handler
      end
    end

    def get_handler
      if @handler && self.respond_to?( @handler )
        h = send( @handler )
        return h if h.class.ancestors.include?( DaemonKit::ErrorHandlers::Base )
      end

      return nil
    end
  end
end

class Object
  class << self
    def safely(&block)
      DaemonKit::Safety.run(&block)
    end
  end

  def safely(&block)
    DaemonKit::Safety.run(&block)
  end
end

# Load our error handlers
require 'daemon_kit/error_handlers/base'
require 'daemon_kit/error_handlers/hoptoad'
