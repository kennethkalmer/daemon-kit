module DaemonKit

  # Provide some advanced helpers for managing access to instance variables.
  module Configurable

    def self.included(base) #:nodoc:
      base.class_eval <<-EOF
        @configurables = {}
        @configurable_defaults = {}

        class << self
          attr_reader :configurables, :configurable_defaults
        end
      EOF

      base.extend( ClassMethods )
      base.send( :include, InstanceMethods )
    end

    module ClassMethods

      # Create a configurable value on any instance, which can contain
      # a default value, and/or be locked.
      #
      # Create a standard getter/setter without a default value
      #
      #   configurable :foo
      #
      # Create a getter/setter with a default value
      #
      #   configurable :foo, true
      #
      # The final argument can be an options hash, which currently
      # respects only one key: +locked+ (false by default). Locking a
      # configurable means the value can only be set once by the
      # setter method.
      #
      #   configurable :foo, :locked => true
      #
      # As long as the getter method (+foo+) returns nil, the standard
      # setter method will work. As soon as the getter returns a
      # non-nil value the setter won't set a new value. To set a new
      # value you'll have to explicitly use the #set instance method.
      def configurable( name, *args )
        opts = args.last.is_a?( Hash ) ? args.pop : {}
        opts = { :locked => false }.merge( opts )

        default = args.size <= 1 ? args.pop : args

        name = name.to_sym

        self.configurables[ name ] = opts
        self.configurable_defaults[ name ] = default

        class_eval( <<-EOF, __FILE__, __LINE__ )
          def #{name}                                    # def foo
            if _configurables[:#{name}].nil?             #   if _configurables[:foo].nil?
              self.class.configurable_defaults[:#{name}] #     self.class.configurable_defaults[:foo]
            else                                         #   else
              _configurables[:#{name}]                   #     _configurables[:foo]
            end                                          #   end
          end                                            #

          def #{name}=( value )                              # def foo=( value )
            if #{name}.nil? ||                               #   if foo.nil? ||
                !self.class.configurables[:#{name}][:locked] #       !self.class.configurables[:foo][:locked]
                                                             #
              _configurables[:#{name}] = value               #     _configurables[:foo] = value
            end                                              #   end
          end                                                # end
        EOF
      end

    end

    module InstanceMethods

      # Force the value of a configurable to be set without any
      # respect for it's locked status.
      def set( name, value )
        name = name.to_sym

        if self.class.configurables.has_key?( name )
          _configurables[ name ] = value
        end
      end

      private

      def _configurables
        @_configurables ||= {}
      end

    end
  end
end
