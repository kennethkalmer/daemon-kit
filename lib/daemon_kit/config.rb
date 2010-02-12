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
        config = config.to_s
        config += '.yml' unless config =~ /\.yml$/

        path = File.join( DAEMON_ROOT, 'config', config )

        raise ArgumentError, "Can't find #{path}" unless File.exists?( path )

        new( YAML.load_file( path ) )
      end

      # Return the +config+.yml file as a raw hash.
      def hash( config, symbolize = false )
        self.load( config ).to_h( symbolize )
      end

    end

    # Expects a hash, looks for DAEMON_ENV key
    def initialize( config_data ) #:nodoc:
      if config_data.has_key?( DAEMON_ENV )
        self.data = config_data[ DAEMON_ENV ]
      else
        self.data = config_data
      end
    end

    # Pick out a config by name
    def []( key )
      @data[ key.to_s ]
    end

    # Return the internal hash structure used, optionally symbolizing
    # the first level of keys in the hash
    def to_h( symbolize = false )
      symbolize ? @data.symbolize_keys : @data
    end

    def method_missing( method_name, *args ) #:nodoc:
      unless method_name.to_s =~ /[\w_]+=$/
        #if @data.keys.include?( method_name.to_s )
        #  return @data.send( method_name.to_s )
        #end
        if @data.respond_to?( method_name.to_s )
          return @data.send( method_name.to_s )
        elsif @data.respond_to?( method_name.to_s.gsub(/\-/, '_') )
          return @data.send( method_name.to_s.gsub(/\-/, '_') )
        end
      end

      super
    end

    def data=( hash )
      @data = hash
      class << @data
        def symbolize_keys( hash = self )
          hash.inject({}) { |result, (key, value)|
            new_key = case key
                    when String then key.to_sym
                    else key
                    end
            new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
            result[new_key] = new_value
            result
          }
        end
      end

      extend_hash( @data )
    end

    def extend_hash( hash )
      hash.keys.each do |k|
        hash.instance_eval <<-KEY
          def #{k.gsub(/\-/, '_')}
            fetch("#{k}")
          end
        KEY
      end

      hash.each do |(key, value)|
        case value
          when Hash then extend_hash( value )
        end
      end
    end
  end
end
