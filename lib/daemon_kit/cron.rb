module DaemonKit
  
  # Thin wrapper around rufus-scheduler gem, specifically designed to ease
  # configuration of a scheduler and provide some added simplicity.
  class Cron

    @@instance = nil

    attr_reader :scheduler
    
    class << self
      
      def instance
        @instance ||= new
      end

      def scheduler
        instance.scheduler
      end
      
      private :new

      def run
        DaemonKit.logger.info "Starting rufus-scheduler"

        begin
          instance.scheduler.join
        rescue Interrupt
          DaemonKit.logger.warn "Scheduler interrupted"
        end
      end
    end

    def initialize
      @scheduler = Rufus::Scheduler.start_new
    end
  end
end
