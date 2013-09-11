# -*- encoding: utf-8 -*-
require File.expand_path('../lib/daemon_kit/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Kenneth Kalmer"]
  gem.email         = ["kenneth.kalmer@gmail.com"]
  gem.description   = %q{daemon-kit aims to simplify creating Ruby daemons by providing a sound application skeleton (through a generator), task specific generators (jabber bot, etc) and robust environment management code.}
  gem.summary       = %q{Opinionated framework for Ruby daemons}
  gem.homepage      = %q{http://github.com/kennethkalmer/daemon-kit}
  gem.post_install_message = %q{
For more information on daemon-kit, see http://kit.rubyforge.org/daemon-kit

For usage options, run:

$ daemon-kit -h


}

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "daemon-kit"
  gem.require_paths = ["lib"]
  gem.version       = DaemonKit.version
  gem.license = 'MIT'

  gem.extra_rdoc_files = [
                          "Configuration.txt",
                          "Deployment.txt",
                          "History.txt",
                          "Logging.txt",
                          "README.md",
                          "RuoteParticipants.txt",
                          "TODO.txt",
                         ]

  gem.add_development_dependency(%q<bundler>)
  gem.add_development_dependency(%q<rake>)
  gem.add_development_dependency(%q<rdoc>)
  gem.add_development_dependency(%q<rspec>, ["~> 2.6"])
  gem.add_development_dependency(%q<cucumber>, ["~> 1.3.8"])
  gem.add_development_dependency(%q<aruba>, ["~> 0.5.3"])
  gem.add_development_dependency(%q<SyslogLogger>)

  gem.add_dependency(%q<thor>)
  gem.add_runtime_dependency(%q<eventmachine>, [">= 0.12.10"])
  gem.add_runtime_dependency(%q<safely>, [">= 0.3.1"])
  gem.add_runtime_dependency(%q<i18n>)
end
