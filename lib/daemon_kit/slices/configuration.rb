module DaemonKit
  module Slices
    class Configuration
      include DaemonKit::Slice

      def before_daemonize
        DaemonKit.configuration.load_paths.each do |d|
          $:.unshift( "#{DAEMON_ROOT}/#{d}" ) if File.directory?( "#{DAEMON_ROOT}/#{d}" )
        end
      end

      def after_daemonize
        configure_signal_traps
        configure_backtraces
        set_process_name
      end

      def configure_signal_traps
        # Only exit the process if we're not in the 'test' environment
        term_proc = Proc.new { DaemonKit::Initializer.shutdown( true, DAEMON_ENV != 'test' ) }
        DaemonKit.configuration.trap( 'INT', term_proc )
        DaemonKit.configuration.trap( 'TERM', term_proc )
        at_exit { DaemonKit::Initializer.shutdown }
      end

      def configure_backtraces
        Thread.abort_on_exception = DaemonKit.configuration.backtraces
      end

      def set_process_name
        $0 = DaemonKit.configuration.daemon_name if DaemonKit.configuration.daemon_name
      end
    end
  end
end
