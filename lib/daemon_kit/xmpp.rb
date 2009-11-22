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

      #my_roster.each do |item|
      #  p [ :roster_item, item ]
      #  unless contacts.include?( item.jid )
      #    item.subscription = :none
      #    next
      #  end

      #  if @config['masters'].include?( item.jid )
      #    item.subscription = :both
      #    next
      #  end

      #  if @config['supporters'].include?( item.jid )
      #    item.subscription = :from
      #  end
      #end
    end

    def contacts
      @config['masters'] + @config['supporters']
    end

    def run
      client.run
    end
  end
end
