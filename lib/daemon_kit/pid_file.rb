module DaemonKit

  # Simple pidfile handling for daemon processes
  class PidFile

    def initialize( path )
      @path = path.to_absolute_path
    end

    def exists?
      File.exists?( @path )
    end

    # Returns true if the process is running
    def running?
      return false unless self.exists?

      # Check if process is in existence
      # The simplest way to do this is to send signal '0'
      # (which is a single system call) that doesn't actually
      # send a signal
      begin
        Process.kill(0, self.pid)
        return true
      rescue Errno::ESRCH
        return false
      rescue ::Exception   # for example on EPERM (process exists but does not belong to us)
        return true
      #rescue Errno::EPERM
      #  return false
      end
    end

    # Return the pid contained in the pidfile, or nil
    def pid
      return nil unless self.exists?

      File.open( @path ) { |f|
        return f.gets.to_i
      }
    end

    def ensure_stopped!
      if self.running?
        puts "Process already running with id #{self.pid}"
        exit 1
      end
    end

    def cleanup
      File.delete( @path ) rescue Errno::ENOENT
    end
    alias zap cleanup

    def write!
      File.open( @path, 'w' ) { |f|
        f.puts Process.pid
      }
    end
  end
end
