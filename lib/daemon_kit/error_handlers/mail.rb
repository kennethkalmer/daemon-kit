require DaemonKit.framework_root + '/vendor/tmail'
require 'net/smtp'

module DaemonKit
  module ErrorHandlers
    # Send an email notification of the exception via SMTP.
    class Mail < Base

      # SMTP hostname
      @host = 'localhost'

      # SMTP port
      @port = 25

      # Recipients of the notification
      @recipients = []

      # Subject prefix
      @prefix = '[DAEMON-KIT]'

      # Sender address
      @sender = 'daemon-kit'

      # SMTP username
      @username = nil

      # SMTP password
      @password = nil

      # Authentication mechanism (:plain, :login, or :cram_md5)
      @authentication = nil

      # Use TLS?
      @tls = false

      # Domain used when talking to SMTP server
      @domain = 'localhost.localdomain'

      class << self
        attr_accessor :host, :port, :recipients, :prefix, :sender, :username,
        :password, :authentication, :tls, :domain
      end

      [ :host, :port, :recipients, :prefix, :sender, :username, :password,
        :authentication, :tls, :domain ].each do |cm|
        class_eval(<<-EOM, __FILE__, __LINE__)
          def #{cm}=( val )
            self.class.#{cm} = val
          end
        EOM
      end

      def handle_exception( exception )

        mail = TMail::Mail.new
        mail.to = self.class.recipients
        mail.from = self.class.sender
        mail.subject = "#{self.class.prefix} #{exception.message}"
        mail.set_content_type 'text', 'plain'
        mail.mime_version = '1.0'
        mail.date = Time.now

        mail.body = <<EOF
DaemonKit caught an exception inside #{DaemonKit.configuration.daemon_name}.

Message: #{exception.message}
Backtrace:
#{exception.backtrace.join("\n  ")}

Environment: #{ENV.inspect}
EOF
        begin
          smtp = Net::SMTP.new( self.class.host, self.class.port )
          smtp.enable_starttls_auto if self.class.tls && smtp.respond_to?(:enable_starttls_auto)
          smtp.start( self.class.domain, self.class.username, self.class.password,
                      self.class.authentication ) do |smtp|
            smtp.sendmail( mail.to_s, mail.from, mail.to )
          end
        rescue => e
          DaemonKit.logger.error "Failed to send exception mail: #{e.message}" if DaemonKit.logger
        end
      end
    end
  end
end
