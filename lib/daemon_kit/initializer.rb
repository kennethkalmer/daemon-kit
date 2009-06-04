require 'logger'
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

    def self.shutdown
      DaemonKit.logger.warn "Shutting down #{DaemonKit.configuration.daemon_name}"
      exit
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
      initialize_logger
      initialize_signal_traps

      include_core_lib
      load_postdaemonize_configs

      set_process_name

      DaemonKit.logger.info( "DaemonKit (#{DaemonKit::VERSION}) booted, now running #{DaemonKit.configuration.daemon_name}" )
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
      return if @environment_loaded
      @environment_loaded = true

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

    def initialize_logger
      return if DaemonKit.logger

      unless logger = configuration.logger
        logger = Logger.new( configuration.log_path )
        logger.level = configuration.log_level
      end

      DaemonKit.logger = logger

      DaemonKit.logger.info "DaemonKit (#{DaemonKit::VERSION}) booting in #{DAEMON_ENV} mode"

      configuration.trap("USR1") {
        DaemonKit.logger.level = DaemonKit.logger.debug? ? Logger::INFO : Logger::DEBUG
        DaemonKit.logger.info "Log level changed to #{DaemonKit.logger.debug? ? 'DEBUG' : 'INFO' }"
      }
      configuration.trap("USR2") {
        DaemonKit.logger.level = Logger::DEBUG
        DaemonKit.logger.info "Log level changed to DEBUG"
      }
    end

    def initialize_signal_traps
      term_proc = Proc.new { DaemonKit::Initializer.shutdown }
      configuration.trap( 'INT', term_proc )
      configuration.trap( 'TERM', term_proc )
    end

    def include_core_lib
      if File.exists?( core_lib = File.join( DAEMON_ROOT, 'lib', configuration.daemon_name + '.rb' ) )
        require core_lib
      end
    end

    def set_process_name
      $0 = configuration.daemon_name
    end
  end

  # Holds our various configuration values
  class Configuration
    # Root to the daemon
    attr_reader :root_path

    # List of load paths
    attr_accessor :load_paths

    # The log level to use, defaults to DEBUG
    attr_accessor :log_level

    # Path to the log file, defaults to 'log/<environment>.log'
    attr_accessor :log_path

    # Provide a custom logger to use
    attr_accessor :logger

    # Path to the pid file, defaults to 'log/<daemon_name>.pid'
    attr_accessor :pid_file

    # The application name
    attr_accessor :daemon_name

    # Use the force kill patch? Give the number of seconds
    attr_accessor :force_kill_wait

    # Collection of signal traps
    attr_reader :signal_traps

    # Our safety net (#Safety) instance
    attr_accessor :safety_net

    def initialize
      parse_arguments!

      set_root_path!
      set_daemon_defaults!

      self.load_paths = default_load_paths
      self.log_level  = default_log_level
      self.log_path   = default_log_path

      self.force_kill_wait = false

      self.safety_net = DaemonKit::Safety.instance

      @signal_traps = {}
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

      unless @signal_traps.has_key?( signal )
        set_trap( signal )
      end

      @signal_traps[signal].unshift( proc || block )
    end

    def pid_file
      @pid_file ||= "#{File.dirname(self.log_path)}/#{self.daemon_name}.pid"
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
        # Pathname is incompatible with Windows, but Windows doesn't have
        # real symlinks so File.expand_path is safe.
        #if RUBY_PLATFORM =~ /(:?mswin|mingw)/
        #  File.expand_path(::DAEMON_ROOT)

        # Otherwise use Pathname#realpath which respects symlinks.
        #else
        #  File.expand_path( Pathname.new(::DAEMON_ROOT).realpath.to_s )
        #end

      Object.const_set(:RELATIVE_DAEMON_ROOT, ::DAEMON_ROOT.dup) unless defined?(::RELATIVE_DAEMON_ROOT)
      ::DAEMON_ROOT.replace @root_path
    end

    def set_daemon_defaults!
    end

    def default_load_paths
      [ 'lib' ]
    end

    def default_log_path
      File.join(root_path, 'log', "#{environment}.log")
    end

    def default_log_level
      environment == 'production' ? Logger::INFO : Logger::DEBUG
    end

    def error( msg )
      msg = "[E] Configuration: #{msg}"

      if DaemonKit.logger
        DaemonKit.logger.error( msg )
      else
        STDERR.puts msg
      end
    end
  end


end
