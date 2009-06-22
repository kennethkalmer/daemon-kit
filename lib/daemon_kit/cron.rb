module DaemonKit

  # Thin wrapper around rufus-scheduler gem, specifically designed to ease
  # configuration of a scheduler and provide some added simplicity.
  #
  # For more information on rufus-scheduler, please visit the RDoc's
  # at http://rufus.rubyforge.org/rufus-scheduler/
  #
  # To use the evented scheduler, call #DaemonKit::EM.run prior to
  # setting up your first schedule.
  class Cron

    @instance = nil

    attr_reader :scheduler

    class << self

      # Access to the scheduler instance
      def instance
        @instance ||= new
      end

      def scheduler
        instance.scheduler
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
    end
  end
end
