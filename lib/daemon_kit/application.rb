require 'daemons'

module DaemonKit

  # Class responsible for making the daemons run and keep them running.
  class Application

    class << self

      # Run the file as a daemon
      def run( file )
        raise DaemonNotFound.new( file ) unless File.exist?( file )

        app_name = DaemonKit.configuration.daemon_name || File.basename( file )
        options = { :backtrace => true, :log_output => true, :app_name => app_name }

        options[:dir_mode]        = DaemonKit.configuration.dir_mode || :normal
        options[:dir]             = DaemonKit.configuration.dir      || "log"
        options[:multiple]        = DaemonKit.configuration.multiple
        options[:force_kill_wait] = DaemonKit.configuration.force_kill_wait if DaemonKit.configuration.force_kill_wait

        Daemons.run( file, options )
      end

      # Call this from inside a daemonized process to complete the
      # initialization process
      def running!
        DaemonKit::Initializer.continue!
      end

    end

  end
end
