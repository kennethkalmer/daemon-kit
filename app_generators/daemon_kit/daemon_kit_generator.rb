class DaemonKitGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  default_options :shebang => DEFAULT_SHEBANG,
  :author => nil

  attr_reader :daemon_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @daemon_name = base_name
    extract_options
  end

  def manifest
    script_options = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }
    
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''

      # Create stubs
      # m.template "template.rb",  "some_file_after_erb.rb"
      # m.template_copy_each ["template.rb", "template2.rb"]
      # m.file     "file",         "some_file_copied"
      # m.file_copy_each ["path/to/file", "path/to/file2"]
      
      # Executables
      m.directory "bin"
      m.template  "bin/daemon.erb", "bin/#{daemon_name}.rb", script_options
      m.directory "libexec"
      m.template  "libexec/daemon.erb", "libexec/#{daemon_name}.rb"

      # Config/Environment
      m.directory "config"
      m.template  "config/boot.erb", "config/boot.rb"
      m.template  "config/environment.erb", "config/environment.rb"

      # Libraries
      m.directory "lib"
      
      # Tests
      m.directory "tasks"
      m.dependency "install_rspec", [daemon_name], :destination => destination_root, :collision => :force

      # Others
      m.directory "log"
      m.directory "tmp"
      m.directory "vendor"

      m.dependency "install_rubigen_scripts", [destination_root, 'daemon_kit'],
        :shebang => options[:shebang], :collision => :force
    end
  end

  protected
    def banner
      <<-EOS
Creates a ...

USAGE: #{spec.name} name
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |o| options[:author] = o }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end

end
