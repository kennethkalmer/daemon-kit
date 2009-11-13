module DaemonKit
  class Timeline

    # The timeline of every daemon's lifespan
    @sequence = [
      'framework',
      'arguments',
      'environment',
      'dependencies',
      'before_daemonize',
      'after_daemonize',
      'application',
      'shutdown'
    ].freeze

    # A list of subscribers for our timeline events.
    @subscribers = {}

    class << self

      attr_reader :sequence, :subscribers

    end
  end
end
