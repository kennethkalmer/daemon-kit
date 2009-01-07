require 'daemons'

module DaemonKit

  # Class responsible for making the daemons run and keep them running.
  class Application

    class << self
      
      # Run the file as a daemon
      def run( file )
        raise DaemonNotFound.new( file ) unless File.exist?( file )
        
        app_name = DaemonKit.config.daemon_name || File.basename( file )
        options = { :backtrace => true, :log_output => true, :app_name => app_name }

        options[:multiple] = DaemonKit.config.multiple
        options[:force_kill_wait] = DaemonKit.config.force_kill_wait if DaemonKit.config.force_kill_wait

        Daemons.run( file, options )
      end
      
    end
    
  end
end
