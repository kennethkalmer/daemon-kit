class DeployCapistranoGenerator < RubiGen::Base

  attr_reader :name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
  end

  def manifest
    record do |m|

      m.file      "Capfile", "Capfile"
      m.directory "config"
      m.template  "config/deploy.rb", "config/deploy.rb"
      m.directory "config/deploy"
      m.template  "config/deploy/staging.rb", "config/deploy/staging.rb"
      m.template  "config/deploy/production.rb", "config/deploy/production.rb"
      m.directory "config/environments"
      m.file      "config/environments/staging.rb", "config/environments/staging.rb", :collision => :skip
      m.readme    "USAGE"
    end
  end

  protected
    def banner
      <<-EOS
Creates the required capistrano configurations for deploying your daemon code
to remote servers.

USAGE: #{$0} #{spec.name} daemon-name
EOS
    end
end
