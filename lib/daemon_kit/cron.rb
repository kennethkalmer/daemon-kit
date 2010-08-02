module DaemonKit

  # Thin wrapper around rufus-scheduler gem, specifically designed to ease
  # configuration of a scheduler and provide some added simplicity. It also
  # logs any exceptions that occur inside the scheduled blocks, ensuring your
  # code isn't running blind.
  #
  # For more information on rufus-scheduler, please visit the RDoc's
  # at http://rufus.rubyforge.org/rufus-scheduler/
  #
  # To use the evented scheduler, call #DaemonKit::EM.run prior to
  # setting up your first schedule.
  class Cron

    @instance = nil
    @exception_handler = nil

    attr_reader :scheduler
    attr_accessor :exception_handler

    class << self

      def instance
        @instance ||= new
      end

      # Access to the scheduler instance
      def scheduler
        instance.scheduler
      end

      # Define a block for receiving exceptions from inside the scheduler
      def handle_exception( &block )
        instance.exception_handler = block
      end

      private :new

      # Once the scheduler has been configured, call #run to block the
      # current thread and keep the process alive for the scheduled
      # tasks to run
      def run
        DaemonKit.logger.info "Starting rufus-scheduler"

        if instance.is_a?( Rufus::Scheduler::PlainScheduler )
          instance.scheduler.join
        else
          Thread.stop
        end
      end
    end

    def initialize
      @scheduler = Rufus::Scheduler.start_new

      def @scheduler.handle_exception( job, exception )
        DaemonKit::Cron.instance.handle_exception( job, exception )
      end
    end

    def handle_exception( job, exception )
      DaemonKit.logger.error( "Cron: job #{job.job_id} caught exception: '#{exception}'" )
      DaemonKit.logger.exception( exception )
      @exception_handler.call( job, exception ) unless @exception_handler.nil?
    end
  end
end
