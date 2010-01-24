require 'yaml'

module DaemonKit
  # Thin wrapper around xmpp4r-simple, specifically designed to ease
  # configuration of a jabber daemon and provide some added simplicity.
  class Jabber

    # Jabber connection
    attr_reader :connection

    @@instance = nil
    @@message_handler = nil
    @@presence_handler = nil
    @@subscription_handler = nil

    class << self

      # Deliver a message to the specified jid.
      def deliver( jid, message )
        instance.connection.deliver( jid, message )
      end

      # Use this instead of initializing, keeps it singleton
      def instance
        @instance ||= new
        @instance.startup!
      end
      private :new

      def run
        DaemonKit.logger.warn "Please use the new XMPP daemons, this class is deprecated"
        DaemonKit.logger.info "Starting jabber loop"

        loop do
          process_messages
          process_updates
          process_subscriptions

          begin
            sleep 1
          rescue Interrupt
            DaemonKit.logger.warn "Jabber loop interrupted"
            break
          end
        end
      end

      def process_messages
        @message_handler ||= Proc.new { |m| DaemonKit.logger.info "Received message from #{m.from}: #{m.body}" }

        instance.valid_messages { |m| @message_handler.call(m) }
      end

      def process_updates
        @presence_handler ||= Proc.new { |friend, old_presence, new_presence|
          DaemonKit.logger.debug "Received presence update: #{friend} went from #{old_presence} to #{new_presence}"
        }

        instance.connection.presence_updates { |friend, old_presence, new_presence|
          @presence_handler.call(friend, old_presence, new_presence)
        }

      end

      def process_subscriptions
        @subscription_handler ||= Proc.new { |friend,presence| DaemonKit.logger.debug "Received presence update from #{friend}: #{presence}" }

        instance.connection.subscription_requests { |friend,presence| @subscription_handler.call(friend,presence) }
      end

      def received_messages(&block)
        @message_handler = block
      end

      def presence_updates(&block)
        @presence_handler = block
      end

      def subscription_requests(&block)
        @subscription_handler = block
      end

    end

    def initialize
      options = DaemonKit::Config.load( 'jabber' )

      @jabber_id  = options.delete("jabber_id")
      @password   = options.delete("password")
      @resource   = options.delete("resource") || 'daemon_kit'
      @masters    = options.delete("masters") || []
      @supporters = options.delete("supporters") || []

      raise ArgumentError if [ @jabber_id, @password ].any? { |a| a.nil? }
    end

    def startup!
      return self if @booted

      connect!
      setup_roster!

      DaemonKit.trap( 'INT', Proc.new { self.shutdown! } )
      DaemonKit.trap( 'TERM', Proc.new { self.shutdown! } )

      @booted = true

      self
    end

    def shutdown!
      DaemonKit.logger.warn "Disconnecting jabber connection"
      self.connection.disconnect
    end

    def contacts
      @masters + @supporters
    end

    def valid_messages(&block)
      self.connection.received_messages.each do |message|
        next unless valid_master?( message.from )

        busy do
          block.call message
        end
      end
    end

    def valid_master?( jid )
      @masters.include?( jid.strip.to_s )
    end

    def busy(&block)
      self.connection.status(:dnd, "Working...")
      yield
      self.connection.status(:chat, self.status_line )
    end

    def status_line
      "#{DaemonKit.configuration.daemon_name} ready for instructions"
    end

    private

    def connect!
      jid = @jabber_id + '/' + @resource

      @connection = ::Jabber::Simple.new( jid, @password, nil, self.status_line )
    end

    def setup_roster!
      # cleanup the roster
      self.connection.roster.items.each_pair do |jid, roster_item|
        jid = jid.strip.to_s
        unless self.contacts.include?( jid )
          self.connection.remove( jid )
        end
      end

      # add missing contacts
      self.contacts.each do |jid|
        unless self.connection.subscribed_to?( jid )
          self.connection.add( jid )
          #self.connection.accept_subscription( jid )
        end
      end
    end

  end
end
