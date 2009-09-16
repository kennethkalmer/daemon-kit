class DaemonKitGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  VALID_GENERATORS = ['default', 'jabber', 'cron', 'amqp', 'nanite_agent', 'ruote']

  DEPLOYERS = ['none', 'capistrano']

  TEST_FRAMEWORKS = [ 'rspec', 'test_unit' ]

  default_options :shebang => DEFAULT_SHEBANG, :author => nil

  attr_reader :daemon_name
  attr_reader :installer
  attr_reader :deployer
  attr_reader :cucumber
  attr_reader :test_framework

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @daemon_name = base_name
    extract_options
  end

  def manifest
    # ensure some sanity
    unless VALID_GENERATORS.include?( installer )
      $stderr.puts "Invalid generator: '#{installer}'."
      $stderr.puts "Valid generators are: #{VALID_GENERATORS.join(', ')}"
      exit 1
    end

    unless DEPLOYERS.include?( deployer )
      $stderr.puts "Invalid deployment mechanism: '#{deployer}'."
      $stderr.puts "Valid deployers are: #{DEPLOYERS.join(', ')}"
      exit 1
    end

    script_options = { :chmod => 0755, :shebang => options[:shebang] == DEFAULT_SHEBANG ? nil : options[:shebang] }

    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''

      # Create stubs
      # m.template "template.rb",  "some_file_after_erb.rb"
      # m.template_copy_each ["template.rb", "template2.rb"]
      # m.file     "file",         "some_file_copied"
      # m.file_copy_each ["path/to/file", "path/to/file2"]

      # Readme
      m.template  "README", "README"
      m.template  "Rakefile", "Rakefile"

      # Executable
      m.directory "bin"
      m.template  "bin/daemon.erb", "bin/#{daemon_name}", script_options

      # Generator
      if installer == "default"
        m.directory "libexec"
        m.template  "libexec/daemon.erb", "libexec/#{daemon_name}-daemon.rb"
      else
        m.dependency installer, [daemon_name], :destination => destination_root, :collision => :force
      end

      # Config/Environment
      m.directory "config"
      m.file      "config/arguments.rb", "config/arguments.rb"
      m.file      "config/boot.rb", "config/boot.rb"
      m.template  "config/environment.rb", "config/environment.rb"
      m.directory "config/environments"
      %w{ development test production }.each { |f| m.file "config/environments/#{f}.rb", "config/environments/#{f}.rb" }
      m.directory "config/pre-daemonize"
      m.file      "config/pre-daemonize/readme", "config/pre-daemonize/readme"
      m.directory "config/post-daemonize"
      m.file      "config/post-daemonize/readme", "config/post-daemonize/readme"
      m.directory "script"
      m.file      "script/destroy", "script/destroy", script_options
      m.file      "script/console", "script/console", script_options
      m.file      "script/generate", "script/generate", script_options

      # Libraries
      m.directory "lib"
      m.file "lib/daemon.rb", "lib/#{daemon_name}.rb", :collision => :skip

      # Tasks
      m.directory "tasks"

      # Tests
      case test_framework
      when 'rspec'
        m.dependency "rspec", [daemon_name], :destination => destination_root, :collision => :force
      when 'test_unit'
        m.dependency "test_unit", [daemon_name], :destination => destination_root, :collision => :force
      end

      if cucumber
        m.dependency "cucumber", [], :destination => destination_root, :collision => :force
      end

      # Deployers
      unless deployer == 'none'
        m.dependency "deploy_#{deployer}", [daemon_name], :destination => destination_root, :collision => :force
      end

      # Others
      m.directory "log"
      m.directory "tmp"
      m.directory "vendor"
    end
  end

  protected
    def banner
      <<-EOS
Creates a preconfigured environment for writing Ruby daemon processes.

USAGE: #{spec.name} /path/to/your/daemon [options]
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

      opts.on("-i", "--install=generator", String,
              "Select a generator to use (other than the default).",
              "Available generators: #{VALID_GENERATORS.join(', ')}",
              "Defaults to: default") do |installer|
        options[:installer] = installer
      end

      opts.on("-d", "--deploy-with=config", String,
              "Select an optional deployment mechanism.",
              "Available deployers: #{DEPLOYERS.join(', ')}",
              "Defaults to: none") do |deploy|
        options[:deployer] = deploy
      end

      opts.on("-T", "--test-with=type", String,
              "Select your test framework.",
              "Available test framworks: #{TEST_FRAMEWORKS.join(', ')}",
              "Defaults to: rspec") do |test|
        options[:test_framework] = test
      end

      opts.on("--cucumber",
              "Install cucumber.") do
        options[:cucumber] = true
      end

      opts.on("-r", "--ruby=path", String,
              "Path to the Ruby binary of your choice (otherwise scripts use env, dispatchers current path).",
              "Default: #{DEFAULT_SHEBANG}") { |x| options[:shebang] = x }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
      @installer = options[:installer] || 'default'
      @deployer  = (options[:deployer] || 'none').strip
      @cucumber  = options[:cucumber]  || false
      @test_framework = options[:test_framework] || 'rspec'
    end

end
