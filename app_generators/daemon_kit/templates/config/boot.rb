# Don't change this file!
# Configure your daemon in config/environment.rb

DAEMON_ROOT = "#{File.dirname(__FILE__)}/.." unless defined?( DAEMON_ROOT )

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
      require 'rubygems'
      gem 'daemon-kit'
      require 'daemon_kit/initializer'
    rescue Gem::LoadError => e
      $stderr.puts %(Missing the daemon-kit gem. Please 'gem install daemon_kit')
      exit 1
    end
  end
end

DaemonKit.boot!
