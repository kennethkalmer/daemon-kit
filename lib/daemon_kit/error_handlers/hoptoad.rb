require 'net/http'

module DaemonKit
  module ErrorHandlers
    # Error reporting via Hoptoad.
    class Hoptoad < Base

      # Your hoptoad API key
      @api_key = nil
      attr_accessor :api_key

      def handle_exception( exception )
        headers = {
          'Content-type' => 'application/x-yaml',
          'Accept' => 'text/xml, application/xml'
        }

        http = Net::HTTP.new( url.host, url.port )
        data = clean_exception( exception )

        response = begin
                     http.post( url.path, {"notice" => data}.to_yaml, headers )
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
        URI.parse("http://hoptoadapp.com/notices/")
      end

      def clean_exception( exception )
        data = {
          :api_key       => self.api_key,
          :error_class   => exception.class.name,
          :error_message => "#{exception.class.name}: #{exception.message}",
          :backtrace     => exception.backtrace,
          :environment   => ENV.to_hash,
          :request       => {},
          :session       => {}
        }

        stringify_keys( data )
      end

      def stringify_keys(hash) #:nodoc:
        hash.inject({}) do |h, pair|
          h[pair.first.to_s] = pair.last.is_a?(Hash) ? stringify_keys(pair.last) : pair.last
          h
        end
      end
    end
  end
end
