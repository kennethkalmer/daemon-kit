module DaemonKit

  # Simple statefile (argv) handling for daemon processes
  class StateFile

    def initialize( path )
      @path = path.to_absolute_path
    end

    def exists?
      File.exists?( @path )
    end

    def state
      return nil unless self.exists?

      YAML.load_file(@path)
    end

    def cleanup
      File.delete( @path ) rescue Errno::ENOENT
    end
    alias zap cleanup

    def write!(argv)
      File.open( @path, 'w' ) { |f|
        f.puts argv
      }
    end

    def self.state
      state_file = StateFile.new( DaemonKit.configuration.state_file )
      state_file.state
    end

    def self.write(configs, args)
      state_file = StateFile.new( DaemonKit.configuration.state_file )
      state = {:configs => configs, :args => args}.to_yaml
      state_file.write!(state)
    end

    def self.cleanup
      state_file = StateFile.new( DaemonKit.configuration.state_file )
      state_file.cleanup
    end
  end
end
