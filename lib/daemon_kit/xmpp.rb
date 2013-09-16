require 'blather/client/client'
require 'blather/client/dsl'
require 'blather/version'

module DaemonKit
  # Thin wrapper around the blather DSL
  class XMPP
    include ::Blather::DSL

    class << self

      def run( &block )
        if Blather::VERSION < '0.8.0'
          DaemonKit.logger.warn "Blather version to old, please upgrade to 0.8.x"
        end

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

      # host & port allow nil, defaults to the jabber id host and default port
      # so if those keys are not present in the config, its ok.
      setup jid, @config.password, @config.host, @config.port

      when_ready do
        configure_roster!
        become_available
      end

      return if @config['require_master'] == false

      message do |m|
        trusted?( m ) ? pass : halt
      end
    end

    def configure_roster!
      DaemonKit.logger.debug 'Configuring roster'

      my_roster.each do |item|
        unless valid_contact?( item.jid )
          DaemonKit.logger.debug "Removing #{item.jid} from roster"

          my_roster.delete( item.jid )
          next
        end
      end

      contacts.each do |jid|
        DaemonKit.logger.debug "Adding #{jid} to roster"

        my_roster.add( Blather::JID.new( jid ) )
      end

      my_roster.each do |item|
        item.subscription = :both
        item.ask = :subscribe
      end
    end

    def become_available
      set_status( :chat, "#{DaemonKit.configuration.daemon_name} is available" )
    end

    def trusted?( message )
      @config.masters.include?( message.from.stripped.to_s )
    end

    def contacts
      @config.masters | ( @config.supporters || [] )
    end

    def valid_contact?( jid )
      contacts.include?( jid.stripped.to_s )
    end

    def run
      client.run
    end

    def busy( message = nil, &block )
      set_status( :dnd, message )

      block.call

      become_available
    end

  end
end
