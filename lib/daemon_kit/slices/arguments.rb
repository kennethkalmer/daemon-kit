module DaemonKit
  module Slices
    class Arguments
      include DaemonKit::Slice

      def arguments
        DaemonKit.arguments = ArgumentParser.new

        cascade!

        DaemonKit.arguments.parse( ARGV.dup )
      end
    end
  end
end
