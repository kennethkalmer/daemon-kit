# Shamelessly taken from http://blog.rapleaf.com/dev/?p=19

require 'rubygems'
require 'daemons'
require 'timeout'

module Daemons

  class ApplicationGroup

    # We want to redefine find_applications to not rely on
    # pidfiles (e.g. find application if pidfile is gone)
    # We recreate the pid files if they're not there.
    def find_applications(dir)
      # Find pid_files, like original implementation
      pid_files = PidFile.find_files(dir, app_name)
      @monitor = Monitor.find(dir, app_name + '_monitor')
      pid_files.reject! {|f| f =~ /_monitor.pid$/}
      
      # Find the missing pids based on the UNIX pids
      pidfile_pids = pid_files.map {|pf| PidFile.existing(pf).pid}
      missing_pids = unix_pids - pidfile_pids

      # Create pidfiles that are gone
      if missing_pids.size > 0
        puts "[daemons_ext]: #{missing_pids.size} missing pidfiles: " + 
             "#{missing_pids.inspect}... creating pid file(s)."
        missing_pids.each do |pid|
          pidfile = PidFile.new(dir, app_name, multiple)
          pidfile.pid = pid # Doesn't seem to matter if it's a string or Fixnum
        end
      end

      # Now get all the pid file again
      pid_files = PidFile.find_files(dir, app_name)

      return pid_files.map {|f|
        app = Application.new(self, {}, PidFile.existing(f))
        setup_app(app)
        app
      }
    end

    # Specify :force_kill_wait => (seconds to wait) and this method will
    # block until the process is dead.  It first sends a TERM signal, then
    # a KILL signal (-9) if the process hasn't died after the wait time.
    def stop_all(force = false)
      @monitor.stop if @monitor
      
      wait = options[:force_kill_wait].to_i
      if wait > 0
        puts "[daemons_ext]: Killing #{app_name} with force after #{wait} secs."

        # Send term first, don't delete PID files.
        @applications.each {|a| a.send_sig('TERM')}

        begin
          started_at = Time.now
          Timeout::timeout(wait) do
            num_pids = unix_pids.size
            while num_pids > 0
              time_left = wait - (Time.now - started_at)
              puts "[daemons_ext]: Waiting #{time_left.round} secs on " +
                   "#{num_pids} #{app_name}(s)..."
              sleep 1
              num_pids = unix_pids.size
            end 
          end
        rescue Timeout::Error
          @applications.each {|a| a.send_sig('KILL')}
        ensure
          # Delete Pidfiles
          @applications.each {|a| a.zap!}
        end

        puts "[daemons_ext]: All #{app_name}(s) dead."
      else
        @applications.each {|a| 
          if force
            begin; a.stop; rescue ::Exception; end
          else
            a.stop
          end
        }
      end
    end
    
    private

    # Find UNIX pids based on app_name.  CAUTION: This has only been tested on
    # Mac OS X and CentOS.
    def unix_pids
      pids = []
      x = `ps auxw | grep -v grep | awk '{print $2, $11}' | grep #{app_name}`
      if x && x.chomp!
        processes = x.split(/\n/).compact
        processes = processes.delete_if do |p|
          pid, name = p.split(/\s/)
          # We want to make sure that the first part of the process name matches
          # so that app_name matches app_name_22
          app_name != name[0..(app_name.length - 1)]
        end
        pids = processes.map {|p| p.split(/\s/)[0].to_i}
      end

      pids
    end

  end

  class Application

    # Send signal to the process, rescue if process deson't exist
    def send_sig(sig)
      Process.kill(sig, @pid.pid) rescue Errno::ESRCH
    end

  end

end
