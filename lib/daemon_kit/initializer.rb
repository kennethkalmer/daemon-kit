require 'pathname'

DAEMON_ENV = (ENV['DAEMON_ENV'] || 'development').dup unless defined?(DAEMON_ENV)

# Absolute paths to the daemon_kit libraries added to $:
require File.dirname(__FILE__) + '/core_ext'
$LOAD_PATH.unshift( File.expand_path('../', __FILE__).to_absolute_path ) unless
  $LOAD_PATH.include?( File.expand_path('../', __FILE__).to_absolute_path )

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

    attr_reader :configuration

    def self.run
      configuration = DaemonKit.configuration || Configuration.new

      yield configuration if block_given?
      initializer = new configuration
      initializer.before_daemonize
      initializer
    end

    def self.continue!
      initializer = new DaemonKit.configuration
      initializer.after_daemonize
    end

    def self.shutdown( clean = false, do_exit = false )
      return unless $daemon_kit_shutdown_hooks_ran.nil?
      $daemon_kit_shutdown_hooks_ran = true

      DaemonKit.logger.info "Running shutdown hooks"

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

    def initialize( configuration )
      @configuration = configuration
    end

    def before_daemonize
      DaemonKit.configuration = @configuration

      set_load_path
      load_gems
      load_patches
      load_environment
      load_predaemonize_configs
    end

    def after_daemonize
      set_umask

      initialize_logger
      initialize_signal_traps

      include_core_lib
      load_postdaemonize_configs
      configure_backtraces

      set_process_name

      DaemonKit.logger.info( "DaemonKit (#{DaemonKit::VERSION}) booted, now running #{DaemonKit.configuration.daemon_name}" )

      if DaemonKit.configuration.user || DaemonKit.configuration.group
        euid = Process.euid
        egid = Process.egid
        uid = Process.uid
        gid = Process.gid
        DaemonKit.logger.info( "DaemonKit dropped privileges to: #{euid} (EUID), #{egid} (EGID), #{uid} (UID), #{gid} (GID)"  )
      end
    end

    def set_load_path
      configuration.load_paths.each do |d|
        $:.unshift( "#{DAEMON_ROOT}/#{d}" ) if File.directory?( "#{DAEMON_ROOT}/#{d}" )
      end
    end

    def load_gems

    end

    def load_patches

    end

    def load_environment
      # Needs to be global to prevent loading the files twice
      return if $_daemon_environment_loaded
      $_daemon_environment_loaded = true

      config = configuration

      eval(IO.read(configuration.environment_path), binding, configuration.environment_path)

      eval(IO.read(configuration.daemon_initializer), binding, configuration.daemon_initializer) if File.exist?( configuration.daemon_initializer )
    end

    def load_predaemonize_configs
      Dir[ File.join( DAEMON_ROOT, 'config', 'pre-daemonize', '*.rb' ) ].each do |f|
        next if File.basename( f ) == File.basename( configuration.daemon_initializer )

        require f
      end
    end

    def load_postdaemonize_configs
      Dir[ File.join( DAEMON_ROOT, 'config', 'post-daemonize', '*.rb' ) ].each do |f|
        require f
      end
    end

    def set_umask
      File.umask configuration.umask
    end

    def initialize_logger
      return if DaemonKit.logger

      unless logger = configuration.logger
        logger = AbstractLogger.new( configuration.log_path )
        logger.level = configuration.log_level
        logger.copy_to_stdout = configuration.log_stdout
      end

      DaemonKit.logger = logger

      DaemonKit.logger.info "DaemonKit (#{DaemonKit::VERSION}) booting in #{DAEMON_ENV} mode"

      configuration.trap("USR1") {
        DaemonKit.logger.level = DaemonKit.logger.debug? ? :info : :debug
        DaemonKit.logger.info "Log level changed to #{DaemonKit.logger.debug? ? 'DEBUG' : 'INFO' }"
      }
      configuration.trap("USR2") {
        DaemonKit.logger.level = :debug
        DaemonKit.logger.info "Log level changed to DEBUG"
      }
      configuration.trap("HUP") {
        DaemonKit::Application.reopen_logs
      }
    end

    def initialize_signal_traps
      # Only exit the process if we're not in the 'test' environment
      term_proc = Proc.new { DaemonKit::Initializer.shutdown( true, DAEMON_ENV != 'test' ) }
      configuration.trap( 'INT', term_proc )
      configuration.trap( 'TERM', term_proc )
      at_exit { DaemonKit::Initializer.shutdown }
    end

    def include_core_lib
      if File.exists?( core_lib = File.join( DAEMON_ROOT, 'lib', configuration.daemon_name + '.rb' ) )
        require core_lib
      end
    end

    def configure_backtraces
      Thread.abort_on_exception = configuration.backtraces
    end

    def set_process_name
      $0 = configuration.daemon_name
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
  end

  # Holds our various configuration values
  class Configuration

    include Configurable

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

    def initialize
      parse_arguments!

      set_root_path!
      set_daemon_defaults!

      self.load_paths = default_load_paths
      self.log_level  ||= default_log_level
      self.log_path   ||= default_log_path

      self.force_kill_wait = false

      self.safety_net = DaemonKit::Safety.instance

      @signal_traps = {}
      @shutdown_hooks = []
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

    def parse_arguments!
      return unless own_args?

      configs = Arguments.configuration( ARGV ).first
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

    # DANGEROUS: Change the value of DAEMON_ENV
    def environment=( env )
      ::DAEMON_ENV.replace( env )
    end

    def set_root_path!
      raise "DAEMON_ROOT is not set" unless defined?(::DAEMON_ROOT)
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
      !%w( rake cap spec cucumber ).include?( File.basename( $0 ) )
    end
  end


end
