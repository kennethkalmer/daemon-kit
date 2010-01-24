require 'daemon_kit/generators/base'

module DaemonKit
  module Generators
    autoload :AppGenerator, 'generators/daemon_kit/app/app_generator'
    autoload :CucumberGenerator, 'generators/daemon_kit/cucumber/cucumber_generator'
  end
end
