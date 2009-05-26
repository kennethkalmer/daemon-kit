class DeployCapistranoGenerator < RubiGen::Base

  default_options :author => nil

  attr_reader :name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @name = args.shift
    extract_options
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
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{$0} #{spec.name} name
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |o| options[:author] = o }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end
