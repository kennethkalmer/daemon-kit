module DaemonKit
  class DSL
    include DaemonKit::Slice

    def initialize( &block )
      instance_eval( &block )
    end

    def use( *args, &block )
      DaemonKit.configuration.stack.use( *args, &block )
    end

    def arguments( &block )
      on :arguments do
        block.call
      end
    end

    def environment( &block )
      on :environment do
        block.call( DaemonKit.configuration )
      end
    end

    def before_daemonize( &block )
      on :before_daemonize do
        block.call
      end
    end

    def after_daemonize( &block )
      on :after_daemonize do
        block.call
      end
    end

    def daemonize( &block )
      on :after_daemonize do
        DaemonKit.configuration.daemonized_code = block
      end
    end

    def shutdown( &block )
      on :shutdown do
        block.call
      end
    end
  end
end
