module DaemonKit
  # Thin wrapper around the blather DSL
  class XMPP
    include ::Blather::DSL

    class << self

      def run( &block )
        DaemonKit::EM.run

        xmpp = new

        xmpp.instance_eval( &block )

        xmpp.run
      end
    end

    def initialize
      @config = DaemonKit::Config.load('jabber')

      jid = if @config.resource
        "#{@config.jabber_id}/#{@config.resource}"
      else
        @config.jabber_id
      end

      setup jid, @config.password
    end
  end
end
