module DaemonKit
  module Slices
    class Arguments
      include DaemonKit::Slice

      def arguments
        command, configs, args = ArgumentParser.parse( ARGV.dup )

        DaemonKit.arguments = ArgumentParser.new
        DaemonKit.arguments.parse( args )
      end
    end
  end
end
