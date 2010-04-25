module DaemonKit
  class Stack < ::Array

    class StackEntry

      def self.new( klass, *args, &block )
        if klass.is_a?( self )
          klass
        else
          super
        end
      end

      attr_reader :args, :block

      def initialize( klass, *args, &block )
        @klass = klass

        options = args.pop if args.last.is_a?( Hash )
        options ||= {}

        if options.has_key?( :if )
          @conditional = options.delete(:if)
        else
          @conditional = true
        end
        args << options unless options.empty?

        @args = args
        @block = block
      end

      def klass
        if @klass.respond_to?(:new)
          @klass
        elsif @klass.respond_to?(:call)
          @klass.call
        else
          @klass.to_s.split('::').inject( Object ) { |p, k| p.const_get( k ) }
        end
      end

      def active?
        return false unless klass

        if @conditional.respond_to?(:call)
          @conditional.call
        else
          @conditional
        end
      end

      def ==( stackentry )
        case stackentry
        when StackEntry
          klass == stackentry.klass
        when Class
          klass == stackentry
        else
          klass == stackentry.to_s.split('::').inject( Object ) { |p,k| p.const_get( k ) }
        end
      end

      def inspect
        str = klass.to_s
        args.each { |arg| str += ", #{build_args.inspect}" }
        str
      end

      def build
        if block
          klass.new( *build_args, &block )
        else
          klass.new( *build_args )
        end
      end

      def instance
        @instance ||= build
      end

      private

      def build_args
        Array(args).map { |arg| arg.respond_to?(:call) ? arg.call : arg }
      end
    end

    def initialize(*args, &block)
      super(*args)
      instance_eval(&block)
    end

    def insert(index, *args, &block)
      index = self.index(index) unless index.is_a?(Integer)
      stackentry = StackEntry.new(*args, &block)
      super(index, stackentry)
    end

    alias_method :insert_before, :insert

    def insert_after(index, *args, &block)
      index = self.index(index) unless index.is_a?(Integer)
      insert(index + 1, *args, &block)
    end

    def swap(target, *args, &block)
      insert_before(target, *args, &block)
      delete(target)
    end

    def use(*args, &block)
      stackentry = StackEntry.new(*args, &block)
      push(stackentry)
    end

    def active
      find_all { |stackentry| stackentry.active? }
    end

    def run!( step )
      active.each do |entry|
        entry.instance.handle_event!( step )
      end
    end

  end
end
