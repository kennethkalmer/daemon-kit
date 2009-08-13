module DaemonKit
  # The core of daemon-kit exceptions
  class Exception < ::StandardError
  end

  # Raised when no class is registered to process a ruote workitem
  class MissingParticipant < Exception; end

  # Raised when the daemon itself cannot be found.
  class DaemonNotFound < Exception
    def initialize( file )
      super "No daemon found at the path '#{file}'"
    end
  end
end
