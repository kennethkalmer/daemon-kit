module DaemonKit

  # EventMachine forms a critical part of the daemon-kit toolset, and
  # especially of daemon process developers.
  #
  # This class abstracts away the difficulties of managing multiple
  # libraries that all utilize the event reactor.
  class EM

    class << self

      # Start a reactor, just like classical EM.run. If the block is
      # provided, the method will block and call the provided block
      # argument inside the running reactor. If the block argument is
      # not provided the reactor will be started in a separate thread
      # and the program will continue to run after the method. All the
      # signal traps are configured to shutdown the reactor when the
      # daemon exists.
      def run(&block)
        if ::EM.reactor_running?
          DaemonKit.logger.warn "EventMachine reactor already running"
          block.call if block_given?

        else
          if block_given?
            ::EM.run { block.call }
          else
            Thread.main[:_dk_reactor] = Thread.new { EM.run {} }
            DaemonKit.trap( 'INT' ) { DaemonKit::EM.stop  }
            DaemonKit.trap( 'TERM' ) { DaemonKit::EM.stop }
          end
        end
      end

      # Stop the reactor
      def stop
        ::EM.stop_event_loop if ::EM.reactor_running?
        Thread.main[:_dk_reactor].join
      end
    end

  end
end
