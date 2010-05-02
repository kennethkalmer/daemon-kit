require 'optparse'

module DaemonKit

  # A wrapper around OptParse for setting up arguments to the daemon
  # process.
  class ArgumentParser

    # Default command
    @default_command = 'run'

    # Valid commands
    @commands = [ 'start', 'stop', 'run' ]

    class << self

      attr_reader :default_command, :commands

    end

    # Options from the command-line
    attr_reader :options

    # The parser
    attr_reader :parser

    # The given command
    attr_reader :command

    def initialize
      @options = {}

      @parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{File.basename($0)} [command] [options]"

        opts.separator ""

        opts.separator "Command is one of the following:"
        opts.separator "    run   - Run the daemon without forking (default)"
        opts.separator "    start - Run the daemon"
        opts.separator "    stop  - Stop the running daemon"

        opts.separator ""

        opts.separator "Options can be:"

        opts.on("-e", "--env ENVIRONMENT", "Environment for the process", "Defaults to development") do |env|
          # Nothing, just here for show
          DaemonKit.configuration.send(:environment=, env)
        end

        opts.on("--pidfile PATH", "Path to the pidfile", "Defaults to log/#{DaemonKit.configuration.daemon_name}.pid") do |path|
          DaemonKit.configuration.pid_file = path
        end

        opts.on("-l", "--log /path/to/logfile", "Path to the log file", "Defaults to log/[environment].log") do |path|
          DaemonKit.configuration.log_path = path
        end

        opts.separator ""
        opts.separator "Advanced configurations:"
        opts.on("--config ATTRIBUTE=VALUE",
                "Change values of the daemon-kit Configuration instance",
                "Example: log_dir=/path/to/log-directory") do |config|

          k, v = config.split('=')

          # Call the writer if we have a reader
          DaemonKit.configuration.send("#{k}=", v) if DaemonKit.respond_to?( k )
        end

        opts.separator ""
        opts.separator "Daemon-specific options (if any):"

        arg_file = File.join( DaemonKit.root, 'config', 'arguments.rb' )
        eval(IO.read(arg_file), binding, arg_file) if File.exists?( arg_file )

        opts.on_tail ""

        opts.on_tail "Common options:"
        opts.on_tail("-v", "--version", "Show version information and exit") do
          puts "daemon-kit #{DaemonKit::VERSION} (http://github.com/kennethkalmer/daemon-kit)"
          exit
        end

        opts.on_tail("-h", "--help", "Show this message") do
          DaemonKit.configuration.display_help = true
        end
      end
    end

    def parse( argv )
      @command, argv = self.extract_command( argv )

      @parser.parse!( argv )
    end

    # Parse the provided argument array for a given command, or
    # return the default command and the remaining arguments
    def extract_command( argv )
      # extract command or set default
      cmd = self.class.commands.include?( argv[0] ) ? argv.shift : self.class.default_command

      return cmd.to_sym, argv
    end
  end
end
