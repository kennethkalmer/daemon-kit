# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{daemon-kit}
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kenneth Kalmer"]
  s.date = %q{2009-05-26}
  s.default_executable = %q{daemon_kit}
  s.description = %q{Daemon Kit aims to simplify creating Ruby daemons by providing a sound application skeleton (through a generator), task specific generators (jabber bot, etc) and robust environment management code.  Using simple built-in generators it is easy to created evented and non-evented daemons that perform a multitude of different tasks.  Supported generators:  * Evented and non-evented Jabber Bot (coming next) * Evented and non-evented loops (coming soon) * Queue poller (SQS, AMQP, etc) (coming soon)}
  s.email = ["kenneth.kalmer@gmail.com"]
  s.executables = ["daemon_kit"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "TODO.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "TODO.txt", "app_generators/daemon_kit/USAGE", "app_generators/daemon_kit/daemon_kit_generator.rb", "app_generators/daemon_kit/templates/README", "app_generators/daemon_kit/templates/Rakefile", "app_generators/daemon_kit/templates/bin/daemon.erb", "app_generators/daemon_kit/templates/config/boot.rb", "app_generators/daemon_kit/templates/config/environment.rb", "app_generators/daemon_kit/templates/config/environments/development.rb", "app_generators/daemon_kit/templates/config/environments/production.rb", "app_generators/daemon_kit/templates/config/environments/test.rb", "app_generators/daemon_kit/templates/config/post-daemonize/readme", "app_generators/daemon_kit/templates/config/pre-daemonize/readme", "app_generators/daemon_kit/templates/lib/daemon.rb", "app_generators/daemon_kit/templates/libexec/daemon.erb", "bin/daemon_kit", "daemon_generators/amqp/USAGE", "daemon_generators/amqp/amqp_generator.rb", "daemon_generators/amqp/templates/config/amqp.yml", "daemon_generators/amqp/templates/config/initializers/amqp.rb", "daemon_generators/amqp/templates/libexec/daemon.rb", "daemon_generators/cron/USAGE", "daemon_generators/cron/cron_generator.rb", "daemon_generators/cron/templates/config/initializers/cron.rb", "daemon_generators/cron/templates/libexec/daemon.rb", "daemon_generators/deploy_capistrano/USAGE", "daemon_generators/deploy_capistrano/deploy_capistrano_generator.rb", "daemon_generators/deploy_capistrano/templates/Capfile", "daemon_generators/deploy_capistrano/templates/config/deploy.rb", "daemon_generators/deploy_capistrano/templates/config/deploy/production.rb", "daemon_generators/deploy_capistrano/templates/config/deploy/staging.rb", "daemon_generators/deploy_capistrano/templates/config/environments/staging.rb", "daemon_generators/jabber/USAGE", "daemon_generators/jabber/jabber_generator.rb", "daemon_generators/jabber/templates/config/initializers/jabber.rb", "daemon_generators/jabber/templates/config/jabber.yml", "daemon_generators/jabber/templates/libexec/daemon.rb", "daemon_generators/nanite_agent/USAGE", "daemon_generators/nanite_agent/nanite_agent_generator.rb", "daemon_generators/nanite_agent/templates/config/initializers/nanite_agent.rb", "daemon_generators/nanite_agent/templates/config/nanite.yml", "daemon_generators/nanite_agent/templates/lib/actors/sample.rb", "daemon_generators/nanite_agent/templates/libexec/daemon.rb", "lib/daemon_kit.rb", "lib/daemon_kit/amqp.rb", "lib/daemon_kit/application.rb", "lib/daemon_kit/config.rb", "lib/daemon_kit/cron.rb", "lib/daemon_kit/deployment/capistrano.rb", "lib/daemon_kit/error_handlers/base.rb", "lib/daemon_kit/error_handlers/hoptoad.rb", "lib/daemon_kit/error_handlers/mail.rb", "lib/daemon_kit/initializer.rb", "lib/daemon_kit/jabber.rb", "lib/daemon_kit/nanite.rb", "lib/daemon_kit/nanite/agent.rb", "lib/daemon_kit/patches/force_kill_wait.rb", "lib/daemon_kit/safety.rb", "lib/daemon_kit/tasks.rb", "lib/daemon_kit/tasks/environment.rake", "lib/daemon_kit/tasks/framework.rake", "rubygems_generators/install_rspec/USAGE", "rubygems_generators/install_rspec/install_rspec_generator.rb", "rubygems_generators/install_rspec/templates/spec.rb", "rubygems_generators/install_rspec/templates/spec/spec.opts", "rubygems_generators/install_rspec/templates/spec/spec_helper.rb", "rubygems_generators/install_rspec/templates/tasks/rspec.rake", "script/console", "script/destroy", "script/generate", "script/txt2html", "spec/daemon_kit_spec.rb", "spec/initializer_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/rspec.rake", "test/test_amqp_generator.rb", "test/test_cron_generator.rb", "test/test_daemon-kit_generator.rb", "test/test_daemon_kit_config.rb", "test/test_deploy_capistrano_generator.rb", "test/test_generator_helper.rb", "test/test_helper.rb", "test/test_jabber_generator.rb", "test/test_nanite_agent_generator.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://kit.rubyforge.org/daemon (coming soon)}
  s.post_install_message = %q{
For more information on daemon-kit, see http://daemon-kit.rubyforge.org

To get started quickly run 'daemon_kit' without any arguments


}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{daemon-kit}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Daemon Kit aims to simplify creating Ruby daemons by providing a sound application skeleton (through a generator), task specific generators (jabber bot, etc) and robust environment management code.}
  s.test_files = ["test/test_generator_helper.rb", "test/test_jabber_generator.rb", "test/test_cron_generator.rb", "test/test_amqp_generator.rb", "test/test_nanite_agent_generator.rb", "test/test_daemon-kit_generator.rb", "test/test_daemon_kit_config.rb", "test/test_helper.rb", "test/test_deploy_capistrano_generator.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<daemons>, [">= 1.0.10"])
      s.add_runtime_dependency(%q<rubigen>, [">= 1.5.2"])
      s.add_development_dependency(%q<newgem>, [">= 1.3.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<daemons>, [">= 1.0.10"])
      s.add_dependency(%q<rubigen>, [">= 1.5.2"])
      s.add_dependency(%q<newgem>, [">= 1.3.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<daemons>, [">= 1.0.10"])
    s.add_dependency(%q<rubigen>, [">= 1.5.2"])
    s.add_dependency(%q<newgem>, [">= 1.3.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
