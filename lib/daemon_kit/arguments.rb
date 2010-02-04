require 'optparse'

module DaemonKit

  # A wrapper around OptParse for setting up arguments to the daemon
  # process.
  #
  # TODO: Set rules for basic options that go for all daemons
  # TODO: Load options from config/arguments.rb
  class Arguments

    # Default command
    @default_command = 'run'

    # Valid commands
    @commands = [
                 'start',
                 'stop',
                 'run'
                ]

    class << self

      attr_reader :default_command, :commands

      # Parse the argument values and return an array with the command
      # name, config values and argument values
      def parse( argv )
        cmd, argv = self.command( argv )

        return cmd, *self.configuration( argv )
      end

      # Parse the provided argument array for a given command, or
      # return the default command and the remaining arguments
      def command( argv )
        # extract command or set default
        cmd = self.commands.include?( argv[0] ) ? argv.shift : self.default_command

        return cmd.to_sym, argv
      end

      # Extracts any values for arguments matching '--config' as well
      # as some implication arguments like '-e'. Returns an array with
      # the configs as the first value and the remaing args as the
      # last value.
      #
      # To set a value on the default #Configuration instance, use the
      # following notation:
      #
      #   --config attribute=value
      #
      # The above notation can be used several times to set different
      # values.
      #
      # Special, or 'normal' arguments that are mapped to the default
      # #Configuration instance are listed below:
      #
      #   -e value or --env value => environment
      #   --pid pidfile           => pid_file
      #   -l path or --log path   => /path/to/log/file
      #
      def configuration( argv )
        configs = []

        i = 0
        while i < argv.size
          if argv[i] == "--config"
            argv.delete_at( i )
            configs << argv.delete_at(i)
            next
          end

          if argv[i] == "-e" || argv[i] == "--env"
            argv.delete_at( i )
            configs << "environment=#{argv.delete_at(i)}"
            next
          end

          if argv[i] == "-l" || argv[i] == "--log"
            argv.delete_at( i )
            configs << "log_path=#{argv.delete_at(i)}"
            next
          end

          if argv[i] == "--pidfile"
            argv.delete_at( i )
            configs << "pid_file=#{argv.delete_at(i)}"
            next
          end

          i += 1
        end

        return configs, argv
      end

      # Return the arguments remaining after running through #configuration
      def arguments( argv )
        self.configuration( argv ).last
      end
    end

    attr_reader :options

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

        arg_file = File.join( DaemonKit.root, 'config', 'arguments.rb' )
        eval(IO.read(arg_file), binding, arg_file) if File.exists?( arg_file )

        opts.on("-e", "--env ENVIRONMENT", "Environment for the process", "Defaults to development") do
          # Nothing, just here for show
        end

        opts.on("--pidfile PATH", "Path to the pidfile", "Defaults to log/#{DaemonKit.configuration.daemon_name}.pid") do
          # Nothing, just here for show
        end

        opts.on("-l", "--log /path/to/logfile", "Path to the log file", "Defaults to log/[environment].log") do
          # Nothing, just here for show
        end

        opts.separator ""
        opts.separator "Advanced configurations:"
        opts.on("--config ATTRIBUTE=VALUE",
                "Change values of the daemon-kit Configuration instance",
                "Example: log_dir=/path/to/log-directory") do
          # Nothing, just here for show
        end

        opts.separator ""

        opts.separator "Common options:"
        opts.on("-v", "--version", "Show version information and exit") do
          puts "daemon-kit #{DaemonKit::VERSION} (http://github.com/kennethkalmer/daemon-kit)"
          exit
        end

        opts.on_tail("-h", "--help", "Show this message") do
          puts opts
          exit
        end
      end
    end

    def parse( argv )
      @parser.parse!( argv )
    end
  end
end
