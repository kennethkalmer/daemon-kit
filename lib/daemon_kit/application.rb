require 'timeout'
require 'yaml'

module DaemonKit

  # Class responsible for making the daemons run and keep them running.
  class Application

    class << self

      # Run the specified file as a daemon process.
      def exec( file )
        raise DaemonNotFound.new( file ) unless File.exist?( file )

        DaemonKit.configuration.daemon_name ||= File.basename( file )

        # if configuration owns the args - they get set in configuration
        # TODO - what if configuration does not own the args?
        parsed_configs = {
          :pid_file => DaemonKit.configuration.pid_file,
          :log_path => DaemonKit.configuration.log_path,
          :environment => DaemonKit.configuration.environment
        }

        command, configs, args = Arguments.parse( ARGV )

        case command
        when :run
          parse_arguments( args )

          run( file, parsed_configs, args )
        when :start
          parse_arguments( args )

          start( file, parsed_configs, args )
        when :stop
          stop
        when :restart
          state = StateFile.state
          configs = state[:configs] rescue {}
          args = state[:args] rescue []

          parse_arguments( args )

          DaemonKit.configuration.update_environment_in_a_dangerous_way(configs[:environment]) if configs[:environment]
          DaemonKit.configuration.pid_file = configs[:pid_file] if configs[:pid_file]
          DaemonKit.configuration.log_path = configs[:log_path] if configs[:log_path]

          puts "environment: #{DaemonKit.configuration.environment}"
          puts "log_path: #{DaemonKit.configuration.log_path}"
          puts "pid_file: #{DaemonKit.configuration.pid_file}"

          stop
          start( file, configs, args )
        when :status
          status
        end
      end

      def status
        @pid_file = PidFile.new( DaemonKit.configuration.pid_file )

        puts @pid_file.running? ? "Process running with id #{@pid_file.pid}" : "Nothing running"
      end

      # Run the daemon in the foreground without daemonizing
      def run( file, configs, args )
        @pid_file = PidFile.new( DaemonKit.configuration.pid_file )
        @pid_file.ensure_stopped!
        # @pid_file.write!

        StateFile.write(configs, args)

        self.chroot
        self.clean_fd
        self.redirect_io( true )

        DaemonKit.configuration.log_stdout = true

        require file
      end

      # Run our file properly
      def start( file, configs, args )
        self.drop_privileges
        self.daemonize

        StateFile.write(configs, args)

        self.chroot
        self.clean_fd
        self.redirect_io

        require file
      end

      def stop
        @pid_file = PidFile.new( DaemonKit.configuration.pid_file )

        unless @pid_file.running?
          @pid_file.cleanup
          puts "Nothing to stop"
          exit
        end

        target_pid = @pid_file.pid

        puts "Sending TERM to #{target_pid}"
        Process.kill( 'TERM', target_pid )

        # otherwise restart never succeeds without force_kill_wait
        sleep 0.5

        if seconds = DaemonKit.configuration.force_kill_wait
          begin
            Timeout::timeout( seconds ) do
              loop do
                puts "Waiting #{seconds} seconds for #{target_pid} before sending KILL"

                break unless @pid_file.running?

                seconds -= 1
                sleep 1
              end
            end
          rescue Timeout::Error
            Process.kill( 'KILL', target_pid )
          end
        end

        if @pid_file.running?
          puts "Process still running, leaving pidfile behind! Consider using configuration.force_kill_wait."
        else
          @pid_file.cleanup
        end

        StateFile.cleanup
      end

      # Call this from inside a daemonized process to complete the
      # initialization process
      def running!
        Initializer.continue!

        yield DaemonKit.configuration if block_given?
      end

      # Exit the daemon
      # TODO: Make configurable callback chain
      # TODO: Hook into at_exit()
      def exit!( code = 0 )
      end

      protected

      def parse_arguments( args )
        # Arguments.parser_available = true
        DaemonKit.arguments = Arguments.new
        DaemonKit.arguments.parse( args )
      end

      # Daemonize the process
      def daemonize
        @pid_file = PidFile.new( DaemonKit.configuration.pid_file )
        @pid_file.ensure_stopped!

        if RUBY_VERSION < "1.9"
          exit if fork
          Process.setsid
          exit if fork
        else
          Process.daemon( true, true )
        end

        @pid_file.write!

        # TODO: Convert into shutdown hook
        at_exit { @pid_file.cleanup }
      end

      # Release the old working directory and insure a sensible umask
      # TODO: Make chroot directory configurable
      def chroot
        Dir.chdir '/'
        File.umask 0000
      end

      # Make sure all file descriptors are closed (with the exception
      # of STDIN, STDOUT & STDERR)
      def clean_fd
        ObjectSpace.each_object(IO) do |io|
          unless [STDIN, STDOUT, STDERR].include?(io)
            begin
              unless io.closed?
                io.close
              end
            rescue ::Exception
            end
          end
        end
      end

      # Redirect our IO
      # TODO: make this configurable
      def redirect_io( simulate = false )
        begin
          STDIN.reopen '/dev/null'
        rescue ::Exception
        end

        unless simulate
          STDOUT.reopen '/dev/null', 'a'
          STDERR.reopen '/dev/null', 'a'
        end
      end

      def drop_privileges
        if DaemonKit.configuration.group
          begin
            group = Etc.getgrnam( DaemonKit.configuration.group )
            Process::Sys.setgid( group.gid.to_i )
          rescue => e
            $stderr.puts "Caught exception while trying to drop group privileges: #{e.message}"
          end
        end
        if DaemonKit.configuration.user
          begin
            user = Etc.getpwnam( DaemonKit.configuration.user )
            Process::Sys.setuid( user.uid.to_i )
          rescue => e
            $stderr.puts "Caught exception while trying to drop user privileges: #{e.message}"
          end
        end
      end
    end

  end
end
