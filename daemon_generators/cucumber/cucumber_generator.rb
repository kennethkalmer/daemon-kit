require 'rbconfig'
require 'cucumber/version'

# This generator bootstraps a Rails project for use with Cucumber
class CucumberGenerator < RubiGen::Base
  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  def manifest
    record do |m|
      m.directory 'features/step_definitions'
      m.template  'cucumber_environment.rb', 'config/environments/cucumber.rb',
        :assigns => { :cucumber_version => ::Cucumber::VERSION::STRING }

      m.directory 'features/support'

      #if options[:spork]
      #  m.template  'spork_env.rb',     'features/support/env.rb'
      #else
      m.template  'env.rb',           'features/support/env.rb'
      #end

      m.directory 'tasks'
      m.template  'cucumber.rake',    'tasks/cucumber.rake'

      m.file      'cucumber',         'script/cucumber', {
        :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang]
      }
    end
  end

protected

  def banner
    "Usage: #{$0} cucumber"
  end

end
