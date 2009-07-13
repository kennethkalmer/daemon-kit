module DaemonKit
  # Common convenience methods for making ruote pseudo-participants more DRY
  # and unified
  class RuotePseudoParticipant

    class << self

      attr_reader :exception_handler_method, :exception_handler_block,
        :on_complete_handler_method, :on_complete_handler_block

      # Register a callback method or block that gets called when an exception
      # occurs during the processing of an action. +handler+ can be a symbol or
      # string with a method name, or a block. Both will get the exception as
      # the first parameter, and the block handler will receive the participant
      # instance as the second parameter
      def on_exception( handler = nil, &block )
        @exception_handler_method = handler
        @exception_handler_block = block
      end

      # Register a callback method or block that gets called when the action
      # was successfully completed. Block callbacks get the workitem as
      # parameter.
      def on_complete( handler = nil, &block )
        @on_complete_handler_method = handler
        @on_complete_handler_block = block
      end
    end

    # Current workitem
    attr_reader :workitem

    # Current action
    attr_reader :action

    # Perform the specified action with the provided workitem
    def perform( action, workitem )
      @action, @workitem = action, workitem

      begin
        send( action )
        run_callbacks
      rescue => e
        handle_exception( e )
      end
    end

    def handle_exception( e )
      raise e if self.class.exception_handler_method.nil? && self.class.exception_handler_block.nil?

      if self.class.exception_handler_method
        send( self.class.exception_handler_method, e )
      else
        self.class.exception_handler_block.call( e, self )
      end
    end

    def run_callbacks
      return if self.class.on_complete_handler_block.nil? && self.class.on_complete_handler_method.nil?

      if self.class.on_complete_handler_method
        send( self.class.on_complete_handler_method )
      else
        self.class.on_complete_handler_block.call( workitem )
      end
    end
  end
end
