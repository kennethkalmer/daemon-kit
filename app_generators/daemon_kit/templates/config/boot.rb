# Don't change this file!
# Configure your daemon in config/environment.rb

DAEMON_ROOT = "#{File.expand_path(File.dirname(__FILE__))}/.." unless defined?( DAEMON_ROOT )

module DaemonKit
  class << self
    def boot!
      unless booted?
        pick_boot.run
      end
    end

    def booted?
      defined? DaemonKit::Initializer
    end

    def pick_boot
      (vendor_kit? ? VendorBoot : GemBoot).new
    end

    def vendor_kit?
      File.exists?( "#{DAEMON_ROOT}/vendor/daemon_kit" )
    end
  end

  class Boot
    def run
      load_initializer
      DaemonKit::Initializer.run
    end
  end

  class VendorBoot < Boot
    def load_initializer
      require "#{DAEMON_ROOT}/vendor/daemon_kit/lib/daemon_kit/initializer"
    end
  end

  class GemBoot < Boot
    def load_initializer
      begin
        require 'rubygems'
        gem 'kennethkalmer-daemon-kit'
        require 'daemon_kit/initializer'
      rescue Gem::LoadError
        begin
          gem 'daemon-kit'
          require 'daemon_kit/initializer'
        rescue Gem::LoadError => e
          msg = <<EOF
You are missing the daemon-kit gem. Please install one of the following gems:

* Unstable - sudo gem install kennethkalmer-daemon-kit -s http://gems.github.com/
* Stable   - sudo gem install daemon-kit

NOTE: The 'unstable' gem is loaded first, before falling back to the stable gem!

EOF
          $stderr.puts msg
          exit 1
        end
      end
    end
  end
end

DaemonKit.boot!
