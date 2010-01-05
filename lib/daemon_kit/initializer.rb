require 'pathname'

DAEMON_ENV = (ENV['DAEMON_ENV'] || 'development').dup unless defined?(DAEMON_ENV)

# Absolute paths to the daemon_kit libraries added to $:
incdir = ( File.dirname(__FILE__) + '/..' )
absincdir = if RUBY_PLATFORM =~ /(:?mswin|mingw)/
              File.expand_path( incdir )
            else
              File.expand_path( Pathname.new( incdir ).realpath.to_s )
            end
$:.unshift absincdir unless $:.include?( absincdir )

require 'daemon_kit'

module DaemonKit

  class << self

    def configuration
      @configuration
    end

    def configuration=( configuration )
      @configuration = configuration
    end

    def arguments
      @arguments
    end

    def arguments=( args )
      @arguments = args
    end

    def trap( *args, &block )
      self.configuration.trap( *args, &block )
    end

    def at_shutdown( &block )
      self.configuration.at_shutdown( &block )
    end

  end

  # This class does all the nightmare work of setting up a working
  # environment for your daemon.
  class Initializer

    def self.prepare!
      if DaemonKit.configuration.nil?
        DaemonKit.configuration = Configuration.new

        Configuration.stack.run!( 'framework' )
      end
    end

    def self.boot
      EM.run {
        prepare!

        Configuration.stack.run!( 'arguments' )

        if DaemonKit.configuration.display_help
          puts DaemonKit.arguments.parser
          exit
        else
          DaemonKit.configuration.parse_arguments!
        end

        #yield DaemonKit.configuration if block_given?

        Configuration.stack.run!( 'environment' )
        Configuration.stack.run!( 'before_daemonize' )

        # Daemonize

        Configuration.stack.run!( 'after_daemonize' )

        # Run daemonized code
        DaemonKit.configuration.daemonized_code.call
      }
    end

    def self.shutdown( clean = false, do_exit = false )
      return unless $daemon_kit_shutdown_hooks_ran.nil?
      $daemon_kit_shutdown_hooks_ran = true

      DaemonKit.logger.info "Running shutdown hooks"

      Configuration.stack.run!( 'shutdown' )

      DaemonKit.configuration.shutdown_hooks.each do |hook|
        begin
          hook.call
        rescue => e
          DaemonKit.logger.exception( e )
        end
      end

      log_exceptions if DaemonKit.configuration.backtraces && !clean

      DaemonKit.logger.warn "Shutting down #{DaemonKit.configuration.daemon_name}"

      exit if do_exit
    end

    def self.log_exceptions
      trace_file = File.join( DaemonKit.root, 'log', "backtrace-#{Time.now.strftime('%Y%m%d%H%M%S')}-#{Process.pid}.log" )
      trace_log = Logger.new( trace_file )

      # Find the last exception
      e = nil
      ObjectSpace.each_object {|o|
        if ::Exception === o
          e = o
        end
      }

      trace_log.info "*** Below you'll find the most recent exception thrown, this will likely (but not certainly) be the exception that made #{DaemonKit.configuration.daemon_name} exit abnormally ***"
      trace_log.error e

      trace_log.info "*** Below you'll find all the exception objects in memory, some of them may have been thrown in your application, others may just be in memory because they are standard exceptions ***"
      ObjectSpace.each_object {|o|
        if ::Exception === o
          trace_log.error o
        end
      }

      trace_log.close
    end

    def after_daemonize
      #set_umask

      #initialize_logger
      #initialize_signal_traps

      #include_core_lib
      #load_postdaemonize_configs
      #configure_backtraces

      #set_process_name

      DaemonKit.logger.info( "DaemonKit (#{DaemonKit::VERSION}) booted, now running #{DaemonKit.configuration.daemon_name}" )

      if DaemonKit.configuration.user || DaemonKit.configuration.group
        euid = Process.euid
        egid = Process.egid
        uid = Process.uid
        gid = Process.gid
        DaemonKit.logger.info( "DaemonKit dropped privileges to: #{euid} (EUID), #{egid} (EGID), #{uid} (UID), #{gid} (GID)"  )
      end
    end

  end

  # Holds our various configuration values
  class Configuration

    include Configurable

    # The stack used to run this daemon
    @stack = Stack.new do |stack|

      stack.use DaemonKit::Slices::Arguments
      stack.use DaemonKit::Slices::Configuration
      stack.use DaemonKit::Slices::Environments
      stack.use DaemonKit::Slices::Umask
      stack.use DaemonKit::Slices::Logger
    end

    class << self

      attr_reader :stack
    end

    # Root to the daemon
    attr_reader :root_path

    # List of load paths
    attr_accessor :load_paths

    # Custom logger instance to use
    attr_accessor :logger

    # The log level to use, defaults to DEBUG
    attr_reader :log_level

    # Path to the log file, defaults to 'log/<environment>.log'
    configurable :log_path

    # Duplicate log data to stdout
    attr_accessor :log_stdout

    # Path to the pid file, defaults to 'log/<daemon_name>.pid'
    attr_accessor :pid_file

    # The application name
    configurable :daemon_name, :locked => true

    # Use the force kill patch? Give the number of seconds
    configurable :force_kill_wait

    # Should be log backtraces
    configurable :backtraces, false

    # Configurable umask
    configurable :umask, 0022

    # Configurable user
    configurable :user, :locked => true

    # Confgiruable group
    configurable :group, :locked => true

    # Collection of signal traps
    attr_reader :signal_traps

    # Our safety net (#Safety) instance
    attr_accessor :safety_net

    # :nodoc: Shutdown hooks
    attr_reader :shutdown_hooks

    # A block that is to be daemonized
    attr_accessor :daemonized_code

    # Display the help message
    attr_accessor :display_help

    def initialize
      set_root_path!
      set_daemon_defaults!

      self.load_paths = default_load_paths
      self.log_level  ||= default_log_level
      self.log_path   ||= default_log_path

      self.force_kill_wait = false

      self.safety_net = DaemonKit::Safety.instance

      @signal_traps = {}
      @shutdown_hooks = []

      @display_help = false
    end

    def environment
      ::DAEMON_ENV
    end

    # The path to the current environment's file (<tt>development.rb</tt>, etc.). By
    # default the file is at <tt>config/environments/#{environment}.rb</tt>.
    def environment_path
      "#{root_path}/config/environments/#{environment}.rb"
    end

    def daemon_initializer
      "#{root_path}/config/initializers/#{self.daemon_name}.rb"
    end

    # Add a trap for the specified signal, can be code block or a proc
    def trap( signal, proc = nil, &block )
      return if proc.nil? && !block_given?

      # One step towards running on windows, not enough though
      unless Signal.list.include?( signal )
        DaemonKit.logger.warn( "Trapping #{signal} signals not supported on this platform" )
        return
      end

      unless @signal_traps.has_key?( signal )
        set_trap( signal )
      end

      @signal_traps[signal].unshift( proc || block )
    end

    # Add a block or proc to be called during shutdown
    def at_shutdown( proc = nil, &block )
      return if proc.nil? && !block_given?

      @shutdown_hooks << ( proc || block )
    end

    def pid_file
      @pid_file ||= "#{File.dirname(self.log_path)}/#{self.daemon_name}.pid"
    end

    # Set the log level
    def log_level=( level )
      @log_level = level
      DaemonKit.logger.level = @log_level if DaemonKit.logger
    end

    def parse_arguments!
      return unless own_args?

      configs = ArgumentParser.configuration( ARGV ).first
      @unused_arguments = {}

      configs.each do |c|
        k,v = c.split('=')

        if v.nil?
          error( "#{k} has no value" )
          next
        end

        begin
          if self.respond_to?( k )
            self.send( "#{k}=", v ) # pid_file = /var/run/foo.pid
          else
            @unused_arguments[ k ] = v
          end
        rescue => e
          error( "Couldn't set `#{k}' to `#{v}': #{e.message}" )
        end
      end
    end

    protected

    def run_traps( signal )
      DaemonKit.logger.info "Running signal traps for #{signal}"
      self.signal_traps[ signal ].each { |trap| trap.call }
    end

    private

    def set_trap( signal )
      DaemonKit.logger.info "Setting up trap for #{signal}"
      @signal_traps[ signal ] = []
      Signal.trap( signal, Proc.new { self.run_traps( signal ) } )
    end

    # DANGEROUS: Change the value of DAEMON_ENV
    def environment=( env )
      ::DAEMON_ENV.replace( env )
    end

    def set_root_path!
      unless defined?(::DAEMON_ROOT)
        Object.const_set( :DAEMON_ROOT, Dir.pwd )
      end

      raise "DAEMON_ROOT is not a directory" unless File.directory?(::DAEMON_ROOT)

      @root_path = ::DAEMON_ROOT.to_absolute_path

      Object.const_set(:RELATIVE_DAEMON_ROOT, ::DAEMON_ROOT.dup) unless defined?(::RELATIVE_DAEMON_ROOT)
      ::DAEMON_ROOT.replace @root_path
    end

    def set_daemon_defaults!
      self.log_stdout = false
    end

    def default_load_paths
      [ 'lib' ]
    end

    def default_log_path
      File.join(root_path, 'log', "#{environment}.log")
    end

    def default_log_level
      environment == 'production' ? :info : :debug
    end

    def error( msg )
      msg = "[E] Configuration: #{msg}"

      if DaemonKit.logger
        DaemonKit.logger.error( msg )
      else
        STDERR.puts msg
      end
    end

    # If we are executed with any of these commands, don't allow
    # arguments to be parsed cause they will interfere with the
    # script encapsulating DaemonKit, like capistrano
    def own_args?
      ![ 'cap' ].include?( File.basename( $0 ) )
    end
  end


end
