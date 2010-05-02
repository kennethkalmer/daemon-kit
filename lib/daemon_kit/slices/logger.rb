module DaemonKit
  module Slices
    class Logger
      include DaemonKit::Slice

      def after_daemonize

        return if DaemonKit.logger

        unless logger = configuration.logger
          logger = AbstractLogger.new( configuration.log_path )
          logger.level = configuration.log_level
          logger.copy_to_stdout = configuration.log_stdout
        end

        DaemonKit.logger = logger

        DaemonKit.logger.info "DaemonKit (#{DaemonKit::VERSION}) booting in #{DAEMON_ENV} mode"

        DaemonKit.trap("USR1") {
          DaemonKit.logger.level = DaemonKit.logger.debug? ? :info : :debug
          DaemonKit.logger.info "Log level changed to #{DaemonKit.logger.debug? ? 'DEBUG' : 'INFO' }"
        }
        DaemonKit.trap("USR2") {
          DaemonKit.logger.level = :debug
          DaemonKit.logger.info "Log level changed to DEBUG"
        }
        DaemonKit.trap("HUP") {
          DaemonKit.logger.close
        }
      end

      private

      def configuration
        DaemonKit.configuration
      end

    end
  end
end
