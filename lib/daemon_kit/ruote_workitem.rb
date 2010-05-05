module DaemonKit

  # Dual purpose class that is a) responsible for parsing incoming workitems and
  # delegating to the correct RuotePseudoParticipant, and b) wrapping the
  # workitem hash into something a bit more digestable.
  class RuoteWorkitem

    class << self

       # = Process incoming commands via an AMQP queue
      #
      # Expects a JSON workitem from ruote that has these fields set in
      # fields key:
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
      # == Notes on errors
      #
      # Where daemon-kit detects errors in attempting to parse and delegate the
      # workitems, it will reply to the engine and set the following field with
      # the error information:
      #
      #   daemon_kit.error
      def process( transport, workitem )
        # keep it singleton
        @instance ||= new

        work = parse( workitem )

        # Invalid JSON... mmm
        return if work.nil?

        DaemonKit.logger.warn "Processing workitem that has timed out!" if work.timed_out?

        target, method = parse_command( work )

        if target.nil? || method.nil?
          msg = "Missing target/method in command parameter, or command parameter missing"
          DaemonKit.logger.error( msg )
          work["__error__"] = msg

        elsif target.public_methods.map { |m| m.to_s }.include?( method ) # 1.8.x => [ 'foo' ]
          target.perform( method, work )                                  # 1.9.x => [ :foo ]

        else
          msg = "Workitem cannot be processes: '#{method}' not exposed by #{target.inspect}"
          DaemonKit.logger.error( msg )
          p [ :work, work.inspect ]
          work["__error__"] = msg
        end

        reply_to_engine( transport, work )
      end

      # Extract the class and method name from the workitem, then pick the matching
      # class from the registered list of participants
      def parse_command( work )
        return nil if work['params']['command'].nil?

        _, klass, method = work['params']['command'].split('/')

        instance = RuoteParticipants.instance.participants[ klass ]

        if instance.nil?
          msg = "No instance registered for #{klass}"
          DaemonKit.logger.error( msg )
          raise DaemonKit::MissingParticipant, msg
        end

        return instance, method
      end

      def reply_to_engine( transport, response )
        send( "reply_via_#{transport}", response )
      end

      def reply_via_amqp( response )
        DaemonKit.logger.debug("Replying to engine via AMQP with #{response.inspect}")
        ::MQ.queue( response['params']['reply_queue'] ).publish( response.to_json )

        response
      end

      def parse( workitem )
        begin
          return new( JSON.parse( workitem ) )
        rescue JSON::ParserError => e
          DaemonKit.logger.error "No valid JSON payload found in #{workitem}"
          return nil
        end
      end
    end

    def initialize( workitem = {} )
      @workitem = workitem
    end

    def fei
      @workitem['fei']
    end

    def short_fei
      @short_fei ||=
        '(' + [
               'fei', self.fei['owfe_version'], self.fei['engine_id'],
               self.fei['workflow_definition_url'], self.fei['workflow_definition_name'],
               self.fei['workflow_definition_revision'], self.fei['wfid'],
               self.fei['expression_name'], self.fei['expid']
              ].join(' ') + ')'
    end

    def dispatch_time
      @dispath_time ||= Time.parse( @workitem['dispatch_time'] )
    end

    def last_modified
      @last_modified ||= Time.parse( @workitem['last_modified'] )
    end

    def participant_name
      @workitem['participant_name']
    end

    def has_field?(a)
      self.fields.keys.include?( a )
    end

    def fields
      @workitem['fields'] ||= @workitem['attributes']
    end

    # backwards compatible..

    alias :attributes :fields
    alias :has_attribute? :has_field?


    def []( key )
      self.fields[ key ]
    end

    def []=( key, value )
      self.fields[ key ] = value
    end

    def to_json
      @workitem.to_json
    end

    # Look at the workitem payload and attempt to determine if this workitem
    # has timed out or not. This method will only ever work if you used the
    # +:timeout: parameter was set for the expression.
    def timed_out?
      key = fei['wfid'] + '__' + fei['expid']

      if self.fields["__timeouts__"] && timeout = self.fields["__timeouts__"][ key ]
        return Time.at( timeout.last ) < Time.now
      end

      return false
    end

    def method_missing( method_name, *args )
      if self.fields.keys.include?( method_name.to_s )
        return self.fields[ method_name.to_s ]
      end

      super
    end

  end
end
