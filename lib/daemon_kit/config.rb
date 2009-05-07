module DaemonKit

  # Simplify simple config file loading for daemons. Assumes the
  # config files all live in DAEMON_ROOT/config and are YAML
  # files. Loaded configs are accessed like a hash with string
  # keys.
  #
  # Config files can either be keyed by environment (default behavior)
  # or be a normal hash.
  #
  # Load a config by passing the filename (with or without the .yml
  # extension) to #load.
  #
  # At this stage the configs are read-only.
  #
  # Any of the keys can be called as methods as well.
  class Config

    class << self

      # Load the +config+.yml file from DAEMON_ROOT/config
      def load( config )
        config += '.yml' unless config =~ /\.yml$/

        path = File.join( DAEMON_ROOT, 'config', config )

        raise ArgumentError, "Can't find #{path}" unless File.exists?( path )

        new( YAML.load_file( path ) )
      end

    end

    # Expects a hash, looks for DAEMON_ENV key
    def initialize( config_data ) #:nodoc:
      if config_data.has_key?( DAEMON_ENV )
        @data = config_data[ DAEMON_ENV ]
      else
        @data = config_data
      end
    end

    # Pick out a config by name
    def []( key )
      @data[ key.to_s ]
    end

    # Return the internal hash structure used, optionally symbolizing
    # the first level of keys in the hash
    def to_h( symbolize = false )
      symbolize ? @data.inject({}) { |m,c| m[c[0].to_sym] = c[1]; m } : @data
    end

    def method_missing( method_name, *args ) #:nodoc:
      # don't match setters
      unless method_name.to_s =~ /[\w_]+=$/
        # pick a key if we have it
        return @data[ method_name.to_s ] if @data.keys.include?( method_name.to_s )
      end

      super
    end
  end
end
