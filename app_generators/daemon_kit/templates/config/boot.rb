# Don't change this file!
# Configure your daemon in config/environment.rb

DAEMON_ROOT = "#{File.dirname(__FILE_)}/.." unless defined?( DAEMON_ROOT )

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
      (vendor_kit? ? VerdorBoot : GemBoot).new
    end
    
  end

  class Boot
    def run
      load_initializer
      DaemonKit::Initializer.run
    end
  end

  class VendorBoot
    def load_initializer
      require "#{DAEMON_ROOT}/vendor/daemon_kit/lib/daemon_kit/initializer"
    end
  end
  
  class GemBoot
    def load_initializer
      gem 'daemon_kit'
    rescue Gem::LoadError => e
      $stderr.puts %(Missing the daemon-kit gem. Please `gem install daemon_kit`)
    end
  end
end
