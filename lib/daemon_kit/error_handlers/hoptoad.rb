require 'net/http'

module DaemonKit
  module ErrorHandlers
    # Error reporting via Hoptoad.
    class Hoptoad < Base

      # Front end to parsing the backtrace for each notice
      # (Graciously borrowed from http://github.com/thoughtbot/hoptoad_notifier)
      class Backtrace

        # Handles backtrace parsing line by line
        # (Graciously borrowed from http://github.com/thoughtbot/hoptoad_notifier)
        class Line

          INPUT_FORMAT = %r{^([^:]+):(\d+)(?::in `([^']+)')?$}.freeze

          # The file portion of the line (such as app/models/user.rb)
          attr_reader :file

          # The line number portion of the line
          attr_reader :number

          # The method of the line (such as index)
          attr_reader :method

          # Parses a single line of a given backtrace
          # @param [String] unparsed_line The raw line from +caller+ or some backtrace
          # @return [Line] The parsed backtrace line
          def self.parse(unparsed_line)
            _, file, number, method = unparsed_line.match(INPUT_FORMAT).to_a
            new(file, number, method)
          end

          def initialize(file, number, method)
            self.file   = file
            self.number = number
            self.method = method
          end

          # Reconstructs the line in a readable fashion
          def to_s
            "#{file}:#{number}:in `#{method}'"
          end

          def ==(other)
            to_s == other.to_s
          end

          def inspect
            "<Line:#{to_s}>"
          end

          def to_xml
            data = [ method, file, number ].map { |s| URI.escape( s || 'unknown', %q{"'<>&} ) }
            %q{<line method="%s" file="%s" number="%s" />} % data
          end

          private

          attr_writer :file, :number, :method
        end

        # holder for an Array of Backtrace::Line instances
        attr_reader :lines

        def self.parse(ruby_backtrace, opts = {})
          ruby_lines = split_multiline_backtrace(ruby_backtrace)

          filters = opts[:filters] || []
          filtered_lines = ruby_lines.to_a.map do |line|
            filters.inject(line) do |line, proc|
              proc.call(line)
            end
          end.compact

          lines = filtered_lines.collect do |unparsed_line|
            Line.parse(unparsed_line)
          end

          instance = new(lines)
        end

        def initialize(lines)
          self.lines = lines
        end

        def inspect
          "<Backtrace: " + lines.collect { |line| line.inspect }.join(", ") + ">"
        end

        def ==(other)
          if other.respond_to?(:lines)
            lines == other.lines
          else
            false
          end
        end

        private

        attr_writer :lines

        def self.split_multiline_backtrace(backtrace)
          if backtrace.to_a.size == 1
            backtrace.to_a.first.split(/\n\s*/)
          else
            backtrace
          end
        end
      end

      # Your hoptoad API key
      @api_key = nil
      attr_accessor :api_key

      def handle_exception( exception )
        headers = {
          'Content-type' => 'text/xml',
          'Accept' => 'text/xml, application/xml'
        }

        http = Net::HTTP.new( url.host, url.port )
        data = format_exception( exception )
        DaemonKit.logger.debug("Sending to Hoptoad: #{data}")

        response = begin
                     http.post( url.path, data, headers )
                   rescue TimeoutError => e
                     DaemonKit.logger.error("Timeout while contacting the Hoptoad server.")
                     nil
                   end
        case response
        when Net::HTTPSuccess then
          DaemonKit.logger.info "Hoptoad Success: #{response.class}"
        else
          DaemonKit.logger.error "Hoptoad Failure: #{response.class}\n#{response.body if response.respond_to? :body}"
        end
      end

      def url
        URI.parse("http://hoptoadapp.com/notifier_api/v2/notices")
      end

      def format_exception( exception )
        lines = Backtrace.parse( exception.backtrace )
        exception_message= exception.message
        exception_message.gsub!("\"","&quot;")
        exception_message.gsub!("'","&apos;")
        exception_message.gsub!("&","&amp;")
        exception_message.gsub!("<","&lt;")
        exception_message.gsub!(">","&gt;")

        <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<notice version="2.0">
  <api-key>#{self.api_key}</api-key>
  <notifier>
    <name>daemon-kit</name>
    <version>#{DaemonKit::VERSION}</version>
    <url>http://github.com/kennethkalmer/daemon-kit</url>
  </notifier>
  <error>
    <class>#{exception.class.name}</class>
    <message>#{exception_message}</message>
    <backtrace>
      #{Backtrace.parse( exception.backtrace ).lines.inject('') { |string,line| string << line.to_xml }}
    </backtrace>
  </error>
  <server-environment>
    <project-root>#{DaemonKit.root}</project-root>
    <environment-name>#{DaemonKit.env}</environment-name>
  </server-environment>
</notice>
        EOF
      end
    end

  end
end
