
class InstallRspecGenerator < RubiGen::Base
  
  default_options :author => nil
  
  attr_reader :gem_name, :module_name
  
  def initialize(runtime_args, runtime_options = {})
    super
    @destination_root = File.expand_path(destination_root)
    @gem_name = base_name
    @module_name  = @gem_name.camelcase
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory 'spec'
      m.directory 'tasks'

      m.template           'spec.rb', "spec/#{gem_name}_spec.rb"
      
      m.template_copy_each %w( spec.opts spec_helper.rb ), 'spec'
      m.file_copy_each     %w( rspec.rake ), 'tasks'
    end
  end

  protected
    def banner
      <<-EOS
Install rspec BDD testing support. 

Includes a rake task (tasks/rspec.rake) to be loaded by the root Rakefile,
which provides a "spec" task.

USAGE: #{$0} [options]
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |x| options[:author] = x }
    end
    
    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end