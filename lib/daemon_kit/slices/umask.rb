module DaemonKit
  module Slices
    class Umask
      include DaemonKit::Slice

      def after_daemonize
        File.umask DaemonKit.configuration.umask
      end
    end

  end
end
