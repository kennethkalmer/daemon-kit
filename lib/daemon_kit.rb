# Seems we need to load openssl before em or there are failures all around.
# But we need to consider that people might not have ssl in the first place.
begin
  require 'openssl'
rescue LoadError
end
require 'eventmachine'

require File.dirname(__FILE__) + '/daemon_kit/core_ext'
require File.dirname(__FILE__) + '/daemon_kit/exceptions'

$:.unshift( File.dirname(__FILE__).to_absolute_path ) unless
  $:.include?( File.dirname(__FILE__).to_absolute_path )

module DaemonKit
  VERSION = '0.2'

  autoload :Initializer,    'daemon_kit/initializer'
  autoload :Application,    'daemon_kit/application'
  autoload :Stack,          'daemon_kit/stack'
  autoload :Slice,          'daemon_kit/slice'
  autoload :Arguments,      'daemon_kit/arguments'
  autoload :Config,         'daemon_kit/config'
  autoload :Safety,         'daemon_kit/safety'
  autoload :PidFile,        'daemon_kit/pid_file'
  autoload :AbstractLogger, 'daemon_kit/abstract_logger'
  autoload :EM,             'daemon_kit/em'
  autoload :Configurable,   'daemon_kit/core_ext/configurable'

  module Slices
    autoload :Configuration, 'daemon_kit/slices/configuration'
    autoload :Environments,  'daemon_kit/slices/environments'
    autoload :Umask,         'daemon_kit/slices/umask'
    autoload :Logger,        'daemon_kit/slices/logger'
  end

  autoload :Cron,                   'daemon_kit/cron'
  autoload :Jabber,                 'daemon_kit/jabber'
  autoload :AMQP,                   'daemon_kit/amqp'
  autoload :Nanite,                 'daemon_kit/nanite'
  autoload :RuoteParticipants,      'daemon_kit/ruote_participants'
  autoload :RuoteWorkitem,          'daemon_kit/ruote_workitem'
  autoload :RuotePseudoParticipant, 'daemon_kit/ruote_pseudo_participant'

  class << self
    def logger
      @logger
    end

    def logger=( logger )
      @logger = logger
    end

    def root
      DAEMON_ROOT
    end

    def env
      DAEMON_ENV
    end

    def framework_root
      @framework_root ||= File.join( File.dirname(__FILE__), '..' ).to_absolute_path
    end
  end
end
