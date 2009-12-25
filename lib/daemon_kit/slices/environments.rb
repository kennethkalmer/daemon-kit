module DaemonKit
  module Slices
    class Environments
      include DaemonKit::Slice

      def framework
        config = DaemonKit.configuration

        eval(IO.read(config.environment_path), binding, config.environment_path) if File.exists?( config.environment_path )

        eval(IO.read(config.daemon_initializer), binding, config.daemon_initializer) if File.exist?( config.daemon_initializer )
      end

      def before_daemonize
        Dir[ File.join( DAEMON_ROOT, 'config', 'pre-daemonize', '*.rb' ) ].each do |f|
          next if File.basename( f ) == File.basename( configuration.daemon_initializer )

          require f
        end
      end

      def after_daemonize

        load_core_lib
        load_post_daemonize_configs
      end

      def load_core_lib
        return unless DaemonKit.configuration.daemon_name

        if File.exists?( core_lib = File.join( DAEMON_ROOT, 'lib', DaemonKit.configuration.daemon_name + '.rb' ) )
          require core_lib
        end
      end

      def load_post_daemonize_configs
        Dir[ File.join( DAEMON_ROOT, 'config', 'post-daemonize', '*.rb' ) ].each do |f|
          require f
        end
      end
    end
  end
end
