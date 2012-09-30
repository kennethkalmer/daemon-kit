require "aws/sqs"

module DaemonKit
  # Thin wrapper around the aws-sdk gem, specifically designed to ease
  # configuration of the SQS client
  class SQS

    @@instance = nil

    class << self

      def instance
        @instance ||= new
      end

      private :new

      def run(config = {}, &block)
        instance.run(config, &block)
      end
    end

    def initialize
      @config = DaemonKit::Config.load("sqs").to_h(true)
    end

    def run(config = {}, &block)
      sqs_config = @config.merge(config)
      DaemonKit.logger.debug("AWS::SQS.new(#{sqs_config.inspect})")
      sqs = ::AWS::SQS.new(sqs_config)
      DaemonKit.logger.debug("# => #{sqs.client.inspect}")
      block.call(sqs)
    end
  end
end
