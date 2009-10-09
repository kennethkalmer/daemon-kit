module DaemonKit
  # = HIGHLY EXPERIMENTAL FORK POOL
  #
  # This is a highly experimental piece of code, really, it still needs a
  # lot of testing and a lot of eyes before it goes to master.
  #
  # == Supported Ruby versions
  #
  # I've tested this on OS X 10.5.8 (Leopard) using rvm, here is the results:
  #
  #   1.8.6-p389 -> Works well
  #   1.8.7-p174 -> Works well
  #   1.9.1-p243 -> Unreliable
  #   1.9.2-preview1 -> Unreliable
  #
  # There are some hints that the "forking from inside a thread issue" is OSX
  # specific, I still need to test on gentoo.
  #
  # == Issues with Ruby 1.9
  #
  # Some of the child processes never actually spawns, leaving the parent
  # waiting for processes that will never run. Terminating the daemon will
  # leave detached processes hanging around on the sytem.
  #
  # == Usage
  #
  # If you made it this far, thanks for being brave enough to test it
  #
  #   DaemonKit::ForkPool.process do
  #     # this will be your sub-process
  #     sleep 60
  #   end
  #
  # Set the maximum number of concurrent forks with +DaemonKit::ForkPool.size+
  #
  # Try to keep the number of running forks slightly higher than
  # (cpu's * cpu cores) if the sub-processes are CPU-intensive.
  class ForkPool

    class << self

      # Set the size of the fork pool, defaults to 4
      def size=( num )
        @size = num
      end

      # Return the size of the fork pool, defaults to 4
      def size
        @size ||= 4
      end

      # The queue used by the dispatcher
      def queue
        @queue ||= Queue.new
      end

      # Array of process id's currently running in the pool
      def processes
        @processes ||= []
      end

      # Add the block to the queue for processing
      def process( &block )
        @enqueueing = true

        queue << block
        p [ :queue, queue ]

        run_forks!

        @enqueueing = false
      end

      # Wait for all processes to finish, including the processes that
      # are currently queued for execution.
      def wait
        loop do
          p [ :wait, queue.size, processes, @enqueueing ]
          break if queue.empty? && processes.empty? && !@enqueueing
          sleep 0.1
        end
      end

      private

      def run_forks!
        return if @dispatcher_thread
        Thread.abort_on_exception = true
        p [ :running_forks ]

        @process_mutex = Mutex.new

        @dispatcher_thread = Thread.new do
          loop do
            if block = queue.pop
              p [ :got_block, block, processes.size, size ]

              pid = Kernel.fork do
                p [ :fork, Process.pid, block ]
                safely do
                  block.call
                end
                at_exit { p [:exit, Process.pid] }
              end

              p [ :pid, pid ]

              @process_mutex.synchronize { processes << pid }

              p [ :processes, processes ]

              Thread.new {
                p [ :waiting, pid ]
                Process.wait( pid )
                @process_mutex.synchronize {
                  processes.delete( pid )
                }
                p [ :finished, pid ]
              }

              sleep 0.1 until processes.size < size

            end

            p [ :loop_done ]
            sleep 0.1
          end
        end

        p [ :dispatcher_running ]
      end
    end
  end
end
