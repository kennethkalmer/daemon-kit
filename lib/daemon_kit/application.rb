require 'timeout'

module DaemonKit

  # Class responsible for making the daemons run and keep them running.
  class Application

    class << self

      # Run the specified file as a daemon process.
      def exec( file )
        raise DaemonNotFound.new( file ) unless File.exist?( file )

        DaemonKit.configuration.daemon_name ||= File.basename( file )

        command, configs, args = Arguments.parse( ARGV )

        case command
        when :run
          parse_arguments( args )
          run( file )
        when :start
          parse_arguments( args )
          start( file )
        when :stop
          stop
        end
      end

      # Run the daemon in the foreground without daemonizing
      def run( file )
        self.chroot
        self.clean_fd
        self.redirect_io( true )

        DaemonKit.configuration.log_stdout = true

        require file
      end

      # Run our file properly
      def start( file )
        self.drop_privileges
        self.daemonize
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

      # http://gist.github.com/304739
      #
      # Stolen from Unicorn::Util
      #
      # This reopens ALL logfiles in the process that have been rotated
      # using logrotate(8) (without copytruncate) or similar tools.
      # A +File+ object is considered for reopening if it is:
      #   1) opened with the O_APPEND and O_WRONLY flags
      #   2) opened with an absolute path (starts with "/")
      #   3) the current open file handle does not match its original open path
      #   4) unbuffered (as far as userspace buffering goes, not O_SYNC)
      # Returns the number of files reopened
      def reopen_logs
        nr = 0
        append_flags = File::WRONLY | File::APPEND
        DaemonKit.logger.info "Rotating logs" if DaemonKit.logger

        #logs = [STDOUT, STDERR]
        #logs.each do |fp|
        ObjectSpace.each_object(File) do |fp|
          next if fp.closed?
          next unless (fp.sync && fp.path[0..0] == "/")
          next unless (fp.fcntl(Fcntl::F_GETFL) & append_flags) == append_flags

          begin
            a, b = fp.stat, File.stat(fp.path)
            next if a.ino == b.ino && a.dev == b.dev
          rescue Errno::ENOENT
          end

          open_arg = 'a'
          if fp.respond_to?(:external_encoding) && enc = fp.external_encoding
            open_arg << ":#{enc.to_s}"
            enc = fp.internal_encoding and open_arg << ":#{enc.to_s}"
          end
          DaemonKit.logger.info "Rotating path: #{fp.path}" if DaemonKit.logger
          fp.reopen(fp.path, open_arg)
          fp.sync = true
          nr += 1
        end # each_object
        nr
      end

      protected

      def parse_arguments( args )
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
