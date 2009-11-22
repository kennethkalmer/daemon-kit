require 'blather/client/client'
require 'blather/client/dsl'

module DaemonKit
  # Thin wrapper around the blather DSL
  class XMPP
    include ::Blather::DSL

    class << self

      def run( &block )
        DaemonKit.trap('INT') { ::EM.stop }
        DaemonKit.trap('TERM') { ::EM.stop }

        DaemonKit::EM.run {

          xmpp = new
          xmpp.instance_eval( &block )
          xmpp.run
        }
      end
    end

    def initialize
      @config = DaemonKit::Config.load('xmpp')

      if @config.enable_logging
        Blather.logger = DaemonKit.logger
      end

      jid = if @config.resource
        "#{@config.jabber_id}/#{@config.resource}"
      else
        @config.jabber_id
      end

      setup jid, @config.password

      when_ready { configure_roster! }
    end

    def configure_roster!
      DaemonKit.logger.debug 'Configuring roster'

      my_roster.each do |(jid, item)|
        unless contacts.include?( jid )
          DaemonKit.logger.debug "Removing #{jid} from roster"

          my_roster.delete( item.jid )
          next
        end
      end

      contacts.each do |jid|
        DaemonKit.logger.debug "Adding #{jid} to roster"

        my_roster.add( Blather::JID.new( jid ) )
      end
    end

    def contacts
      @config['masters'] + @config['supporters']
    end

    def run
      client.run
    end
  end
end
