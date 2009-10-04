module Nanite
  class Agent

    attr_accessor :init_block

    def load_actors_with_daemon_kit_changes( &block )
      actors = @options[:actors]
      Dir["#{DaemonKit.root}/lib/actors/*.rb"].each do |actor|
        next if actors && !actors.include?( File.basename(actor, '.rb') )
        Nanite::Log.info( "[setup] loading #{actor}" )
        require actor
      end

      self.init_block.call( self )
    end

    alias_method :load_actors_without_daemon_kit_changes, :load_actors
    alias_method :load_actors, :load_actors_with_daemon_kit_changes
  end
end

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
        ::Nanite::Log.logger = DaemonKit.logger

        # Start our mapper
        mapper_thread = Thread.new do
          EM.run do
            agent = ::Nanite::Agent.new( @config )
            agent.init_block = block
            agent.run
          end
        end

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
