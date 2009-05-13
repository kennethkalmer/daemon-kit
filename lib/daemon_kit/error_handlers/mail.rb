require 'net/smtp'

module DaemonKit
  module ErrorHandlers
    # Send an email notification of the exception via SMTP
    class Mail < Base
      
      # SMTP hostname
      @host = 'localhost'
      attr_accessor :host
      
      # Recipients of the notification
      @recipients = []
      attr_accessor :recipients

      # Subject prefix
      @prefix = '[DAEMON-KIT]'
      attr_accessor :prefix

      # Sender address
      @sender = 'daemon-kit'
      attr_accessor :sender

      def handle_exception( exception )
        email = <<EOF
To: #{self.recipients.map { |r| '<' + r + '>' }.join(', ')}
From: <#{self.sender}>
Subject: #{self.prefix} #{exception.message}
Date: #{Time.now}

DaemonKit caught an exception inside #{DaemonKit.configuration.daemon_name}.

Message: #{exception.message}
Backtrace:
#{exception.backtrace.join("\n  ")}

Environment: #{ENV.inspect}
EOF
        begin
          Net::SMTP.start( self.host ) do |smtp|
            smtp.send_message( email, self.sender, self.recipients )
          end
        rescue
        end
      end
    end
  end
end
