module DaemonKit
  # Responsible for processing the commands coming in over AMQP and
  # delegating it to the correct class.
  class Workitem

    class << self

      # = Process incoming commands via an AMQP queue
      #
      # Expects a JSON workitem from ruote that has these fields set in
      # attributes key:
      #
      #   {
      #     'reply_queue'    => 'queue to send replies to',
      #     'params' => {
      #       'command'  => '/actor/method'
      #     }
      #   }
      #
      # == Notes on the command key:
      #
      # It looks like a resource, and will be treated as such. Is should
      # be in the format of +/class/method+, and it will be passed the
      # complete workitem as a hash.
      #
      # == Notes on replies
      #
      # Replies are sent back to the queue specified in the +reply_queue+ key.
      #
      # == Statusses
      #
      # Status messages are sent via topic exchanges, using the command
      # as they routing key.
      def process( transport, workitem )
        # keep it singleton
        @instance ||= new

        work = JSON.parse( workitem )

        target, method = parse_command( work )

        response = target.send( method, work )

        reply_to_engine( transport, response )
      end

      def parse_command( work )
        _, klass, method = work['attributes']['params']['command'].split('/')

        return RuoteParticipant.instance.participants[ klass ], method
      end

      def reply_to_engine( transport, response )
        send( "reply_via_#{transport}", response )
      end

      def reply_via_amqp( response )
        DaemonKit.logger.debug("Replying to engine via AMQP with #{response.inspect}")

        ::MQ.queue( response['attributes']['reply_queue'] ).publish( response.to_json )

        response
      end
    end

  end
end
