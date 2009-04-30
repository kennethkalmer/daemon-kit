module DaemonKit
  # For building daemons that integrate with nanite, either as mappers
  # or agents. See #DaemonKit::Nanite::Agent so far
  module Nanite
    autoload :Agent, "daemon_kit/nanite/agent"
  end
end
