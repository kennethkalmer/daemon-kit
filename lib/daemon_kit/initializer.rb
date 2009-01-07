require 'logger'
require 'pathname'

DAEMON_ENV = (ENV['DAEMON_ENV'] || 'development').dup unless defined?(DAEMON_ENV)

module DaemonKit

  class << self

    def logger
      @logger
    end

    def logger=( logger )
      @logger = logger
    end
    
  end
  

  # This class does all the nightmare work of setting up a working
  # environment for your daemon.
  class Initializer

    attr_reader :configuration
    
    def self.run( command = :process, configuration = Configuration.new )
      yield configuration if block_given?
      initializer = new configuration
      initializer.send( command )
      initializer
    end
    
    def initialize( configuration )
      @configuration = configuration
    end

    def process
      set_load_path
      load_gems
      load_patches
      load_environment

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
    attr_reader :root_path
    
    attr_accessor :load_paths
    attr_accessor :log_level
    attr_accessor :log_path
    attr_accessor :logger

    def initialize
      set_root_path!
      
      self.load_paths = default_load_paths
      self.log_level  = default_log_level
      self.log_path   = default_log_path
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
      environment == 'production' ? :info : :debug
    end
  end
  
  
end
