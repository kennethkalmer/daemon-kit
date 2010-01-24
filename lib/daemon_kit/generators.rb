require 'daemon_kit/generators/base'

module DaemonKit
  module Generators
    autoload :AppGenerator,         'generators/daemon_kit/app/app_generator'
    autoload :CucumberGenerator,    'generators/daemon_kit/cucumber/cucumber_generator'
    autoload :AmqpGenerator,        'generators/daemon_kit/amqp/amqp_generator'
    autoload :CronGenerator,        'generators/daemon_kit/cron/cron_generator'
    autoload :CapistranoGenerator,  'generators/daemon_kit/capistrano/capistrano_generator'
    autoload :NaniteAgentGenerator, 'generators/daemon_kit/nanite_agent/nanite_agent_generator'
  end
end
