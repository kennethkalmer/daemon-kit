module DaemonKit
  module Slices
    class Arguments
      include DaemonKit::Slice

      def arguments
        command, configs, args = ArgumentParser.parse( ARGV.dup )

        # TODO: This isn't correct, we need to determine the calling command
        # to make sure we don't interfere with things like rake, capistrano,
        # cucumber, spec, etc...
        ArgumentParser.parser_available = true
        DaemonKit.arguments = ArgumentParser.new
        DaemonKit.arguments.parse( args )
      end
    end
  end
end
