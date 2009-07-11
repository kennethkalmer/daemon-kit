module DaemonKit
  # The core of daemon-kit exceptions
  class Exception < ::StandardError
  end

  # Raised when no class is registered to process a ruote workitem
  class MissingParticipant < Exception; end
end
