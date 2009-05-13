module DaemonKit
  module Nanite
    # Pull support into a daemon for being a nanite agent.
    class Agent

      @@instance = nil

      class << self

        def instance
          @instance ||= new
        end

        private :new

        def run(&block)
          instance.run(&block)
        end

      end

      def initialize
        @config = DaemonKit::Config.load( 'nanite' ).to_h( true )

        config_agent
      end

      def run(&block)
        # Ensure graceful shutdown of the connection to the broker
        DaemonKit.trap('INT') { ::EM.stop }
        DaemonKit.trap('TERM') { ::EM.stop }

        # Start our mapper
        mapper_thread = Thread.new do
          EM.run do
            agent = ::Nanite.start_agent( @config )
            block.call( agent ) if block
          end
        end

        #block.call if block

        mapper_thread.join
      end

      private
      
      # Make sure to fine tune the agent config to be DK friendly
      def config_agent
        @config[:root] = DAEMON_ROOT
        @config[:daemonize] = false
        @config[:actors_dir] = File.join(DAEMON_ROOT, 'lib', 'actors')
      end
    end
  end
end
