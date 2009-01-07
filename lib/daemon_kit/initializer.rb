require 'logger'
require 'pathname'

DAEMON_ENV = (ENV['DAEMON_ENV'] || 'development').dup unless defined?(DAEMON_ENV)

$:.unshift File.dirname(__FILE__) + '/..'
require 'daemon_kit'

module DaemonKit

  class << self

    def logger
      @logger
    end

    def logger=( logger )
      @logger = logger
    end

    def configuration
      @configuration
    end

    def configuration=( configuration )
      @configuration = configuration
    end
    
    
  end
  

  # This class does all the nightmare work of setting up a working
  # environment for your daemon.
  class Initializer

    attr_reader :configuration
    
    def self.run( configuration = Configuration.new )
      yield configuration if block_given?
      initializer = new configuration
      initializer.before_daemonize
      initializer
    end

    def self.continue!
      initializer = new DaemonKit.configuration
      initializer.after_daemonize
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
    end

    def after_daemonize
      initialize_logger
    end
    
    def set_load_path
      configuration.load_paths.each do |d|
        $:.unshift( "#{DAEMON_ROOT}/#{d}" ) if File.directory?( "#{DAEMON_ROOT}/#{d}" )
      end
    end

    def load_gems
    end

    def load_patches
      if !!configuration.force_kill_wait
        require 'daemon_kit/patches/force_kill_wait'
      end
    end

    def load_environment
      return if @environment_loaded
      @environment_loaded = true
      
      config = configuration
      
      eval(IO.read(configuration.environment_path), binding, configuration.environment_path)
    end

    def initialize_logger
      return if DaemonKit.logger
      
      unless logger = configuration.logger
        logger = Logger.new( configuration.log_path )
        logger.level = configuration.log_level
      end
      
      DaemonKit.logger = logger

      trap("USR1") do
        DaemonKit.logger.level == Logger::DEBUG ? Logger::INFO : Logger::DEBUG
      end
      trap("USR2") do
        DaemonKit.logger.level = Logger::DEBUG
      end
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

    # The application name
    attr_accessor :daemon_name

    # Allow multiple copies to run?
    attr_accessor :multiple

    # Use the force kill patch? Give the number of seconds
    attr_accessor :force_kill_wait

    def initialize
      set_root_path!
      
      self.load_paths = default_load_paths
      self.log_level  = default_log_level
      self.log_path   = default_log_path

      self.multiple = false
      self.force_kill_wait = false
    end

    def set_root_path!
      raise "DAEMON_ROOT is not set" unless defined?(::DAEMON_ROOT)
      raise "DAEMON_ROOT is not a directory" unless defined?(::DAEMON_ROOT)

      @root_path =
        # Pathname is incompatible with Windows, but Windows doesn't have
        # real symlinks so File.expand_path is safe.
        if RUBY_PLATFORM =~ /(:?mswin|mingw)/
          File.expand_path(::DAEMON_ROOT)

        # Otherwise use Pathname#realpath which respects symlinks.
        else
          Pathname.new(::DAEMON_ROOT).realpath.to_s
        end

      Object.const_set(:RELATIVE_DAEMON_ROOT, ::DAEMON_ROOT.dup) unless defined?(::RELATIVE_DAEMON_ROOT)
      ::DAEMON_ROOT.replace @root_path
    end

    def environment
      ::DAEMON_ENV
    end

    # The path to the current environment's file (<tt>development.rb</tt>, etc.). By
    # default the file is at <tt>config/environments/#{environment}.rb</tt>.
    def environment_path
      "#{root_path}/config/environments/#{environment}.rb"
    end
    
    private

    def default_load_paths
      [ 'lib' ]
    end
    
    def default_log_path
      File.join(root_path, 'log', "#{environment}.log")
    end

    def default_log_level
      environment == 'production' ? Logger::INFO : Logger::DEBUG
    end
  end
  
  
end
